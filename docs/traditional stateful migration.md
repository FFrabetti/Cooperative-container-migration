# Traditional stateful migration #
In [this page](stateful%20migration.md) we have broken down the problem of migrating service state within containerized applications. The proposed methods have to be contextualized in the actual case of a container being migrated to a different node in a stateful way.

***We are considering the simplifying assumption of just one user per container.***

The migration process, at high level, can be summarized as follows:
1. A migration request is issued
2. Some container data is sent to the destination
3. The source container is stopped
4. The remaining data is transferred to the destination
5. A new container is started at the destination

In order for the migration to be as short as possible (thus reducing some QoS parameters of interest not reported here), steps 2 and 4 have to be short and efficiently performed.
They are the steps involving other nodes, so they can be optimized by changing the type of migration from "traditional" to cooperative.

Intuitively, when a migration request is issued, it means that the QoS provided by the current edge node is below a given threshold, so we have all the interest in migrating the service to a (better) target node as quickly as possible, if it can provide the required QoS.
Additionally, between steps 3 and 5 there is a period of service downtime, so keeping it small contributes to the effect of providing a seamless service migration.

> Although the structure of the algorithm is somehow similar to a basic pre-copy, pre-copy, post-copy and other hybrid migration techniques are out of the scope of this work, which is to evaluate the performance improvement of cooperative migration with respect to "traditional" migration, regardless of the method used by the both of them.

## Algorithm details ##
While in stateless migration we could start a new container at the destination _before_ stopping the one at the source, so to avoid any downtime, in the case of stateful migration this is not possible because of the state changes made _during_ the migration process. This very problem is the same of pre-copy: at some point the service must be stopped so that the last incremental changes can be migrated to the destination without experiencing any _other_ changes in the meantime.

To keep things simple, a first idea could be to send all read-only data before step 3, leaving just writable data for step 4. However, without adding too much complexity, we can implement a very simple **one-iteration pre-copy migration** by transferring _all_ data in step 2 and sending in step 4 just those pieces of (writable) data that have been changed.
To do so, we are using [`rsync`](https://rsync.samba.org/), a common tool for incremental file transfer.

We can therefore further detail the steps of migration:
1. A migration request is issued
2. All container data is sent from the source to the destination
   - Container image (just the layers not already present)
   - Read-only volumes _and writable volumes_
   - _Checkpoint of the running container_
3. The source container is stopped
4. Delta changes are transferred to the destination (`rsync`)
   - Checkpointed source container
   - Writable volumes content
5. A new container is started at the destination

> The Container layer is not migrated, to avoid unnecessary additional complexity.

## Script ##
Because most of the stages have already been detailed in previous pages, here we just report the high-level structure of the algorithm in pseudo-code.
Snippets regarding new sections or ones that differ from the cooperative approach are later commented and analysed.

```
procedure migrateStateful(S := source, C := container) : TargetC
	# 2.1 transfer container image (same as for stateless migration)
	ContImage := transferImageLayers(S, C);
	
	# 2.2 transfer volumes
	sendFrom(S, C.VolumesMetadata);
	SendVolContentList := new List;
	AlreadyPresentList := new List;
	foreach Vol in C.VolumesMetadata:
		if Vol.Readonly = false || not isArchivePresent(Vol):
			SendVolContentList.add(Vol);
		if isArchivePresent(Vol):
			AlreadyPresentList.add(Vol);
	VolArchives := copyArchives(AlreadyPresentList);
	ssh S: UtilityC := startContainerVolumesFrom(C);
	       ArchDir := createArchives(UtilityC, SendVolContentList);
	rsyncFrom(S, ArchDir, VolArchives);
	TargetUtilityC := startContainerWithVolumes(C.VolumesMetadata);
	extractArchivesToVol(TargetUtilityC, VolArchives);
	
	# 2.3 transfer checkpoint
	ssh S: CheckptCi := createCheckpoint(C, false); # stopContainer set to false
	sendFrom(S, CheckptCi);
	
	# 3. stop container and 4.1 send checkpoint difference
	ssh S: CheckptCf := createCheckpoint(C, true); # stopContainer set to true
	rsyncFrom(S, CheckptCf, CheckptCi);
	CheckptCf := CheckptCi; # assign local CheckptCf (they are the same after sync)
	
	# 4.2 sync writable volumes content
	WritableVols := filterIfWritable(C.VolumesMetadata);
	ssh S: UtilityC := startContainerVolumesFrom(C);
	       ArchDir := createArchives(UtilityC, WritableVols);
	rsyncFrom(S, ArchDir, VolArchives);
	TargetUtilityC := startContainerWithVolumes(C.VolumesMetadata);
	extractArchivesToVol(TargetUtilityC, VolArchives);
	
	# 5. start target container from checkpoint
	TargetC := startContainerVolumesFrom(ContImage, CheckptCf, TargetUtilityC);
	return TargetC;
```

Step 2.1 is described [here](traditional%20migration.md), while 2.2 and 2.3 in their respective sections [of this page](stateful%20migration.md), where an example for step 5 is reported as well.

The important thing to notice is that all the pieces of information (image layers, volumes content and checkpoints) not already present at the destination are fetched from the source, while the cooperative migration algorithm will have, in general, multiple options.

Here is a possible implementation of steps 3 and 4 in shell scripting:
```
# 3. stop container and create checkpoint
ssh $SOURCE "docker checkpoint create $CONTAINER $CHECKPT_F --checkpoint-dir=\"$REMOTE_CHECKPT_DIR\""

# 4.1 send checkpoint difference
rsyncFrom $SOURCE "$REMOTE_CHECKPT_DIR/$CHECKPOINT_F/" "$CHECKPT_DIR"
sudo cp -r "$CHECKPT_DIR/" "/var/lib/docker/containers/$TARGET_CONTAINER/checkpoints/$CHECKPOINT_F"

# 4.2 sync writable volumes content
while read name destination rw rest; do
	if [ $rw = "true" ]; then
		echo $name "$destination"
	fi
done < "$VOL_LIST" | ssh $SOURCE "$REMOTE_SH_DIR/run_utilc_voltotar.sh $CONTAINER $REMOTE_VOL_BACKUPS"
CHANGED_VOLS=$(rsyncFrom $SOURCE "$REMOTE_VOL_BACKUPS/" "$VOL_BACKUPS")

docker run --volumes-from $UCONT_ID \
	-v "$(pwd)/$VOL_BACKUPS":/backup \
	-v "$TAR_TO_VOL":/tar_to_vol.sh \
	ubuntu /tar_to_vol.sh $CHANGED_VOLS
```
> Minor details are omitted for better clarity. See full script for those.

The complete script can be found [here](../stateful%20migration/tsm_dest.sh).

> Note that `rsync` can also be used with non-archived volumes content, but with some additional complexity due to the isolation of containers file system from their host.

### Example ###
To test our script, we try to migrate a toy container which has some running state (in RAM) and makes use of both a writable and a readonly volume.

Set up:
1. Start a source and a destination node
2. Run a [local Registry](../various/utils/local_registry.sh) on both of them and pull/push a basic `busybox` image from the Docker Registry:

   ```
   local_registry.sh <CERTS_DIR>
   docker pull busybox
   docker tag busybox <REGISTRY_ADDR>/busybox
   docker push <REGISTRY_ADDR>/busybox
   ```
   > This is just to simulate a situation where the destination already has some of the image layers of the migrating container.
3. At the source, create the two volumes and run a container with the sole purpose of writing a file in what will be the readonly one:

   ```
   docker volume create --label rw-guid=$(cat /proc/sys/kernel/random/uuid) testrw
   docker volume create testro
   docker run --rm -v testro:/testro \
		busybox /bin/sh -c 'echo "Read-only content" > /testro/testfile'
   ```
4. Again at the source, create a folder with the following `Dockerfile`:

   ```
   FROM busybox
   COPY layerfile .
   CMD ["/bin/sh", "-c", "i=0; while true; do echo $i | tee -a /testrw/counter; i=$((i+1)); sleep 1; done"]
   ```
   
   then build and push to the local Registry the image of the toy container:
   
   ```
   # cd in the directory with Dockerfile
   for i in $(seq 1 1000); do
		echo "Lorem ipsum dolor sit amet $i" >> layerfile
   done
   
   docker build -t <REGISTRY_ADDR>/testtsm:0.1 .
   docker push <REGISTRY_ADDR>/testtsm:0.1
   ```
5. Finally, run the toy container at the source:
   
   ```
   docker run -d --name toytsm \
		-v testrw:/testrw -v testro:/testro:ro \
		<REGISTRY_ADDR>/testtsm:0.1
   ```

Now we can migrate it to the destination by executing:
```
tsm_dest.sh <SOURCE_ADDR> toytsm
```

In case of success, the script prints the ID of the migrated container. To check that runtime and storage data have actually been migrated to the destination, run:
```
docker logs <TARGET_CONTAINER> | head
# the counting should start from where it was interrupted at the source

docker exec -it <TARGET_CONTAINER> /bin/sh -c 'cat /testrw/counter | head; ls -l /testro'
# the counter file, however, should start from 0
```

#### Example output ####
Because the destination tries to use what already has (mainly read-only volumes, but also writable ones are just synchronized instead of copied), the output of the script changes after the first execution:
```
[...]
/testrw/
/testrw/counter
/testro/
/testro/testfile
receiving incremental file list
./
testro.tar
testrw.tar
[...]
```

to a shorter, optimized, version:
```
[...]
/testrw/
/testrw/counter
receiving incremental file list
./
testrw.tar
[...]
```

As you can see, the read-only volume mounted at `/testro` is not archived nor synchronized in the second migration.

This concept of "caching" content is at the base of cooperative migration, as it enables the destination to receive the required pieces of information from multiple sources.

### Centralized control? ###
Because everything comes from the source, there seems to be no real need for a centralized controller. This, however, does not mean that there couldn't be one for orchestrating purposes, or to send synchronization messages to the source and the destination (e.g. start migration, stop source container, end migration, etc.).

Optionally, there could also be just one Registry running at the master. If this is the case, the previous script has to be executed with a third argument that tells the destionation where to pull the container image from (as the source won't have its own Registry): `<REGISTRY_ADDR>/<IMAGE_REPO>:<IMAGE_TAG>`

### Assumptions and security remarks ###
- We are assuming that **the same image means the exact same service**, which is not usually the case, as every container has its own configuration (volumes, etc.), and can give life to a variety of different services.
- We require that **all writable volumes have a label containing their GUID**.
- We used a simple **Base64 encoding to generate the GUID of read-only volumes** instead of creating a low-collision digest from their content. A proper digest would allow logically different volumes (mounted at different mount points in containers started from any images) to share their content if it is exactly the same, similarly to what happens with image layers.

These points are better explained in [this page](cooperative%20stateful%20migration.md), but they do not change the value of the model, which requires any way to:
- Recognize when two containers represent instances (associated to different users) of the same service/application.
- Identify writable volumes (associated with a specific user-service pair) in a unique way across migrations and changes over time of their content.
- Identify when two read-only volumes have the same content, so it can be re-used.

> The script presents some ***known security issues*** related to `sudo` operations that need to be performed remotely over `ssh`, so **it is meant just for isolated and controlled test environments**.

### References ###
- [rsync](https://download.samba.org/pub/rsync/rsync.html)
- [How Rsync Works](https://rsync.samba.org/how-rsync-works.html)
