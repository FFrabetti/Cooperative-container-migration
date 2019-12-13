# Stateful migration #

We assume the data that needs to be migrated together with a container is only stored in:
- **[The Container layer](#migrating-a-container-layer)**
- **[Volumes](#migrating-volumes)**
- **[RAM](#migrating-running-state-ram)**, for volatile information

## Migrating a Container layer ##

## Migrating volumes ##
With volume migration we mean creating a _new volume_ at the destination with the exact same content of the original one; it will then be mounted into the target container in the same way and with the same configuration options of the original one (read/write or read-only mode, mount propagation, etc.).
We therefore identify two tasks:
- Create a volume at the destination with the same content of the original one
- Mount it into the target container with the same settings

The process of volumes migration can be detailed into the following steps:
1. Given a container, find out its volumes
2. For each volume, back up its content
3. Move the backups to the destination
4. Extract them into corresponding _new volumes_
5. Mount the volumes into the target container (with the right settings)

To keep things simple, we are again considering the scenario of traditional migration, with just one source and one destination.

### Backup volumes content ###
The first step is pretty straightforward, with
```
docker container inspect CONTAINER
docker volume inspect VOLUME
```
two JSON structures can be obtained containing information about mounted volumes (among other things) and a given volume details respectively.

Secondly, for each volume we need to create a backup of its content. Despite having the volume location in the host machine file system reported in the previous data structures, as we are dealing with volumes and not bind mounts we should not interfere with them from processes outside of Docker. Instead, we can use an ad-hoc container sharing the same volumes to access their content and backing it up.

```
docker run --rm --volumes-from CONTAINER \
	-v $(pwd)/backup:/backup \
	ubuntu tar -cPvf /backup/VOLUME.tar VOLUME_MOUNT
```

This container mounts all volumes from `CONTAINER`, plus a bind mount used to store backup files in the host file system (in `$(pwd)/backup`).

`CONTAINER` may be optionally suffixed with `:ro` to mount volumes in read-only mode. By default, volumes are mounted in the same mode as the reference container indicated with `--volumes-from`.

As this needs to be done for all volumes, we can add a loop that takes volumes information (`VOLUME` as the volume name and `VOLUME_MOUNT` as its mount point) from standard input, retrieved with `docker container inspect`:
```
docker container inspect --format='{{range $m := .Mounts}}
{{if eq $m.Type "volume"}} {{$m.Name}} {{$m.Destination}} {{end}}
{{end}}' CONTAINER | docker run \
	--rm --volumes-from CONTAINER:ro \
	-v $(pwd)/backup:/backup \
	-v $(pwd)/vol_to_tar.sh:/vol_to_tar.sh \
	-a stdin -a stdout -i \
	ubuntu /vol_to_tar.sh
```

The actual loop is implemented in its own [script file](../stateful%20migration/vol_to_tar.sh), mounted in the container for better modularity and ease of management.
Similarly, by keeping the steps 1 and 2 described above separated (left and right-hand side of the pipeline), we can easily change things so that just a _subset_ of volumes is backed up (and migrated).

The script containing a cleaned-up version of the above code can be found [here](../stateful%20migration/volumes_backup.sh).


### Restore volumes content ###
The third step can easily be achieved with `scp`, once there is an agreement on where backup files are located in the source host.

For step 4 we need to replicate the backup process the other way around: first we create the volumes and we populate them with the backed up content with the help of a "utility" container, then we mount them into the target container (at its start time).

Creating volumes and mounting them can be done in a single operation, using `-v` or the recommended `--mount` option of `docker run`; for now, default values will do.

> Note that we are using anonymous volumes, so that Docker will take care of generating unique names for them (the names of the respective volumes in the source might already be in use in the destination host), but this means that we have to be careful **not** to use `--rm` or they will be erased by Docker when the container stops.

Our "utility" container, in charge of populating the volumes, also needs a bind mount with the backup files and one for the [bash script](../stateful%20migration/tar_to_vol.sh) that is actually going to extract the archives. It will therefore look like this:
```
docker run -d \
	--mount type=volume,dst=VOLUME_MOUNT_1 \
	...
	--mount type=volume,dst=VOLUME_MOUNT_N \
	-v $(pwd)/backup:/backup \
	-v $(pwd)/tar_to_vol.sh:/tar_to_vol.sh \
	ubuntu /tar_to_vol.sh
```

The very last step is running the target container with the same volumes populated by the previous one:
```
docker run -d --volumes-from UTILITY_CONT TARGET_CONT_IMAGE
```

The restore process (steps 3 and 4) can be performed in one go by executing this [script](../stateful%20migration/volumes_migr_dest.sh) with the right parameters.
An extended version of it will be presented at the end of this section, comprehensive of the issues that are still to be faced.

## Migrating running state (RAM) ##
