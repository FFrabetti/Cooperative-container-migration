# Stateful migration #

We assume the data that needs to be migrated together with a container is only stored in:
- **[The Container layer](#migrating-a-container-layer)**
- **[Volumes](#migrating-volumes)**
- **[RAM](#migrating-running-state-ram)**, for volatile information

## Migrating a Container layer ##

## Migrating volumes ##
With volume migration we mean creating a _new volume_ at the destination with the exact same content of the original one; it will then be mounted into the target container in the same way and with the same configuration options of the original one (read/write or read-only mode, etc.).
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

Secondly, for each volume we need to create a backup of its content. Despite having the volume location in the host machine file system reported in the previous data structures, as we are dealing with volumes and not bind mounts, we should not interfere with them from processes outside of Docker. Instead, we can use an ad-hoc container sharing the same volumes to access their content and backing it up.

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

For step 4 we need to replicate the backup process the other way around: first we create the volumes and we populate them with the backed up content with the help of a "utility" container, then (step 5) we will mount them into the target container _at its start time_.

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

### Migrating volume mount options ###
The second task described above refers to the problem of mounting the newly created volumes at the destination side with the same configuration used at the source. A volume, in fact, is not just its content, but it is also a data structure maintained by Docker with a number of properties/meta-data associated with it.

```
$ docker volume inspect myvolume
[
    {
        "CreatedAt": "2019-12-13T17:37:47-05:00",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/myvolume/_data",
        "Name": "myvolume",
        "Options": null,
        "Scope": "local"
    }
]

$ docker container inspect mycontainer --format='{{json .Mounts}}'
[
	{
		"Type": "volume",
		"Name": "eb30d116...",
		"Source": "/var/lib/docker/volumes/eb30d116.../_data",
		"Destination": "/bar",
		"Driver": "local",
		"Mode": "",
		"RW": true,
		"Propagation": ""
	}
]
```
In this example, `mycontainer` has one anonymous volume whose name - automatically generated - has been truncated here for graphic reasons.

Some of the properties listed above need to be preserved when migrating the volume. This means that the destination has to keep track of the relevant pieces of information for each volume and use them when mounting the corresponding volume into the target container.

- **CreatedAt**: not relevant
- **Driver**: at default is `local`. For simplicity, other drivers are not considered here.
  
  A common scenario is to use drivers to store data in a shared space, so that either a migration is not necessary or it would be strongly driver-specific.
- **Labels**: custom metadata (key-value pairs) applied to the volume upon creation
- **Mountpoint**: not relevant, managed by Docker
- **Name**: not relevant, as anonymous volumes will be mounted at the destination
- **Options**: key-value pairs specific to a given volume driver

  The built-in `local` driver on Linux accepts options similar to the linux `mount` command.
- **Scope**: default `local`. Set to `global` for those volume drivers whose volumes should be created just once for each cluster, instead of once per host

<br/>

- **Type**: `volume`, as we are considering just volumes
- **Name**: not relevant, as anonymous volumes will be mounted at the destination
- **Source**: not relevant, managed by Docker
- **Destination**: already taken care of in the previous section
- **Driver**: just `local` is considered
- **Mode**: nothing or `z` (shared volume) or `Z` (private volume).

  Used for [SELinux labeling](https://docs.docker.com/engine/reference/commandline/run/#mount-volumes-from-container---volumes-from)
- **RW**: default `true`, otherwise the volume is mounted in read-only mode
- **Propagation**: volumes do not support [bind propagation](https://docs.docker.com/engine/reference/commandline/service_create/#bind-propagation) (default `rprivate`), which is only configurable for bind mounts

Of all these properties, we are just interested in: labels, options and read/write mode (`RW`).

> `Mode`: `--mount` does not allow you to relabel a volume with `Z` or `z` flags \[[doc](https://docs.docker.com/engine/reference/commandline/service_create/#differences-between---mount-and---volume)\], while `-v` requires a named volume in order to do that.

> The `Mode` attribute can also store the `nocopy` option when specified via `-v`, but this does not seem to apply to the equivalent `volume-nocopy` for `--mount` (used to disable copying files from the container's filesystem when an empty volume is mounted).

The first problem is how to transmit, for each volume, its attributes to the destination. To keep things simple, we are storing them in a text file which is going to be copied to the destination via `scp`.

```
docker container inspect $CONTAINER --format='{{range $m := .Mounts}}
{{if eq $m.Type "volume"}} {{$m.Name}} {{$m.Destination}} {{$m.RW}} {{end}}
{{end}}' | while read name destination rw; do
	if [ $name ]; then
		labels=$(docker volume inspect $name \
			--format='{{range $l,$v := .Labels}}volume-label={{$l}}={{$v}},{{end}}')
		options=$(docker volume inspect $name \
			--format='{{range $o,$v := .Options}}volume-opt={{$o}}={{$v}},{{end}}')

		echo $name $destination $rw $labels $options
	fi
done >> "$BACKUP_DIR"/volumes.list
```
This is the only significant change from the script presented in the previous section, however, the updated version can be found [here](../stateful%20migration/volumes_backup_attr.sh).

At the destination, this file is used to construct the right `--mount` flag for each volume/line. The code reported below is from [this script](../stateful%20migration/volumes_attr_migr_dest.sh)

```
VOLNAMES=()
VOLNAMES_RO=()
MOUNTSTR=""
MOUNTSTR_RO=""
for list in "$TARGET_DIR"/*.list; do
	while read name destination rw labels options; do
		MOUNT="--mount type=volume,dst=$destination"
		# if there are no labels, then $labels contains options, but that is ok
		if [ $labels ]; then
			labels=$(echo $labels | rev | cut -c 2- | rev)
			MOUNT="$MOUNT,$labels"
		fi
		if [ $options ]; then
			options=$(echo $options | rev | cut -c 2- | rev)
			MOUNT="$MOUNT,$options"
		fi
		
		if [ $rw = "true" ]; then
			MOUNTSTR="$MOUNTSTR $MOUNT"
			VOLNAMES+=($name)
		else
			MOUNTSTR_RO="$MOUNTSTR_RO $MOUNT"
			VOLNAMES_RO+=($name)
		fi
	done < "$list"
done
```

An additional problem arises from read-only volumes: as we are creating and mounting the volumes in the utility container to populate them from the tar archives, we obviously have to mount them in read-write mode. However, when the actual target container "inherits" the volumes with `--volumes-from`, we have to set to read-only those that were so in the source.

We use for that the previously mentioned `:ro` suffix, again to keep things as simple as possible (there surely are more elegant solutions): the list of volumes is split into two groups, with two separate utility containers dedicated to the creation of their volumes.

```
CONT_ID=$(docker run -d \
	-v "$TARGET_DIR":/backup \
	-v $(pwd)/tar_to_vol.sh:/tar_to_vol.sh \
	$MOUNTSTR ubuntu /tar_to_vol.sh ${VOLNAMES[@]})
CONT_ID_RO=$(docker run -d \
	-v "$TARGET_DIR":/backup \
	-v $(pwd)/tar_to_vol.sh:/tar_to_vol.sh \
	$MOUNTSTR_RO ubuntu /tar_to_vol.sh ${VOLNAMES_RO[@]})

docker run -d \
	--volumes-from $CONT_ID \
	--volumes-from $CONT_ID_RO:ro \
	$CONT_IMAGE
```


<br/>
At the end of your tests, remember to clean up all unused volumes:

```
docker volume prune
```

#### References ####
- [Use volumes](https://docs.docker.com/storage/volumes/)
- [docker run - Mount volumes from container (--volumes-from)](https://docs.docker.com/engine/reference/commandline/run/#mount-volumes-from-container---volumes-from)
- [docker run - Mount volume (-v, --read-only)](https://docs.docker.com/engine/reference/commandline/run/#mount-volume--v---read-only)
- [docker service create - Add bind mounts, volumes or memory filesystems](https://docs.docker.com/engine/reference/commandline/service_create/#add-bind-mounts-volumes-or-memory-filesystems)
- [Docker run reference - VOLUME (shared filesystems)](https://docs.docker.com/engine/reference/run/#volume-shared-filesystems)
- [docker volume create](https://docs.docker.com/engine/reference/commandline/volume_create/)
- [Volume plugins - /VolumeDriver.Capabilities](https://docs.docker.com/engine/extend/plugins_volume/#volumedrivercapabilities)


## Migrating running state (RAM) ##
