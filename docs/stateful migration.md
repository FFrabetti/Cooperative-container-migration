# Stateful migration #

We assume the data that needs to be migrated together with a container is only stored in:
- **[The Container layer](#migrating-a-container-layer)**
- **[Volumes](#migrating-volumes)**
- **[RAM](#migrating-runnin-state-ram)**, for volatile information

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

### Backup and restore volumes content ###
The first step is pretty straightforward, with
```
docker container inspect CONTAINER
docker volume inspect VOLUME
```
two JSON structures can be obtained containing the information about mounted volumes (among other things) and a given volume details respectively.

Secondly, for each volume we need to create a backup of its content. Despite having the volume location in the host machine file system reported in the previous data structures, as we are dealing with volumes and not bind mounts, we should not interfere with them from processes outside of Docker. To overcome this problem we can exploit the fact that volumes can be shared among multiple containers, so we can use an ad-hoc container sharing the same volumes to access them instead.

```
docker run --rm --volumes-from CONTAINER \
	-v $(pwd)/backup:/backup \
	ubuntu tar cvf /backup/VOLUME.tar VOLUME_MOUNT
```

The new container mounts all volumes from `CONTAINER`, plus a bind mount used to store backup files in the host file system (in `$(pwd)/backup`).

`CONTAINER` may be optionally suffixed with `:ro` or `:rw` to mount the volumes in read-only or read-write mode respectively (in our case, `:ro` would be the safest option). By default, volumes are mounted in the same mode as the reference container.

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

## Migrating running state (RAM) ##
