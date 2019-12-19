# Stateful migration: migrating service state #
In some cases, starting a new container at the destination from the same base image is not enough to migrate a service. From a logical point of view, it is not the end user that is simply pointing to a different node (the destination) providing the same service with lower latency, but it is the very same logical service "instance" that is _migrated_ from one node to the other.

Migration should therefore keep into account _service state_, which can be classified into:
- Application state: common to all users
- Session state: relative to a particular user (multiple service requests as part of the same _conversation_)
- Request state: information limited to a single request

We start from the consideration that service state can either be kept in memory (RAM) or in a storage medium. From the [options available in Docker](https://docs.docker.com/storage/), we assume the data that needs to be migrated together with a container is only stored in:
- **[The Container layer](#migrating-a-container-layer)**
- **[Volumes](#migrating-volumes)**
- **[RAM](#migrating-running-state-ram)**, for volatile information

This page focuses on how these problems can be solved separately, from the point of view of a single cluster service based on Docker containers. Please refer to [this document](cooperative%20stateful%20migration.md) for the details about all possible cases of stateful migration and for the explanation of a script that puts all pieces together.

## Migrating a Container layer ##
The Container layer is the only writable layer at the top of stack of layers the container image is made of (more details [here](https://docs.docker.com/storage/storagedriver/)). It is important to notice that _it is not the recommended way of storing information within a container_, mainly because its lifespan is the same of the container itself (and containers are ephemeral entities), and because it suffers the performance issues of the Docker union file system.

Because of this, we expect applications to write to the Container layer just temporary files, like cached objects or support files to otherwise memory-intensive operations, or anyway accessory files not vital to the service, possibly related to cross-cutting concerns like logging.

In this scenario, one may say that the Container layer should **not** be migrated in the first place; the container image, in fact, should contain all the information needed for the service to work.
Despite this will be the case of many applications, we try to address the problem of migrating it for those cases in which preserving the Container layer content across migrations is required.

### docker commit ###
One option is to use [`docker commit`](https://docs.docker.com/engine/reference/commandline/commit/) to create a new image from the migrating container, complete of the changes written in the Container layer "committed" into a read-only layer at the top of the newly formed image. Migrating it to the destination, at this point, is no different from a stateless migration.

The downside of this approach is that, when a new container is started at the destination, an additional writable layer is created for future changes. The net result is that, after N migrations, there would be N different images, each of which with an increasing number of layers.

To tame this growth, [layers squashing](https://docs.docker.com/engine/reference/commandline/build/#squash-an-images-layers---squash-experimental) could be used: not so much with the provided `docker build --squash` flag (which generates a single-layer-image from a container image), but with some other tool or hack that merges, after each `commit`, the layers on top of the original container image. Still, after N migrations there would be around N images beside the original one.

### docker export/import ###
These two commands allow you to [export](https://docs.docker.com/engine/reference/commandline/export/)/[import](https://docs.docker.com/engine/reference/commandline/import/) a container file system to/from a tar archive.

Differently from `docker save` and `load`, which would pack up all container metadata but disregard the Container layer, with `export` just the container file system is extracted, exactly as it is seen from within the container itself. As a result, all layers are flattened out in a unified tree structure.

It is immediately obvious how this would compromise the whole idea of exploiting layers already present at the destination, or those otherwise available from neighboring nodes.

### docker diff ###
In addition to the solutions mentioned above, one could write its own hack and inspect, backup and, symmetrically, extract at the destination the content of the Container layer by accessing it from the host file system (somewhere in `/var/lib/docker/<storage-driver>`).

The proposed solution somehow follows this idea, but it tries to exploit available Docker commands and to keep things as portable and simple as possible.

One neat way to access the Container layer is through [`docker diff`](https://docs.docker.com/engine/reference/commandline/diff/): we read from the documentation that it gives us one like for each change recorded in the writable layer, with:
- `A` for added files
- `C` for changed files
- `D` for deleted files

Because we are relying on a union file system, added or changed files have, in fact, to be present in the target Container layer, shadowing or not pre-existing versions from the underlying layers. For deleted files and directories, we know that the implementation is somehow similar to `C` but with special place-holders (in the sense that we are _adding_ special files to shadow others with the same name), but we don't want to deal with them directly.

For `A` and `C` files, we can simply copy them into an archive, transfer it to the destination and extract it within the target container (at default, write operations are made to the Container layer).

```
docker diff $CONTAINER | while read type path; do
	if [ $type = "A" ] || [ $type = "C" ]; then
		echo $path
	fi
done | docker exec -i $CONTAINER bash -c 'tar cPv -T -' > "$TAR_FILE"
```
A revisited version can be found [here](../stateful%20migration/cont_layer_backup.sh), dealing also with mounted volumes and with new and "changed" directories.

At the destination, after getting the archive via `scp`, we have to extract it:

```
docker exec -i $CONTAINER bash -c 'tar xPvf - -C /' < "$TAR_FILE"
```

Deleted files and directories don't have to be transferred and we just need their full path so we can delete them in the target container as well:

```
ssh $SOURCE "docker diff $SRC_CONTAINER" | while read type path; do
	if [ "$type" = "D" ]; then
		echo $path
	fi
done | docker exec -i $CONTAINER bash -c 'while read line; do rm -rv "$line"; done'
```

See [full script](../stateful%20migration/cont_layer_dest.sh).

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

