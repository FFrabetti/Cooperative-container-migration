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
	VolumesList := filterIfAlreadyPresent(C.VolumesMetadata);
	VolArchives := copyArchAlreadyPresent(C.VolumesMetadata);
	ssh S: UtilityC := startContainerVolumesFrom(C);
	       ArchDir := createVolArchives(UtilityC, VolumesList);
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
	foreach WV in WritableVols:
		rsyncFrom(S, WV.Location, UtilityC.Volumes.get(WV.Id).Location);
	
	# 5. start target container
	TargetC := startContainerVolumesFrom(ContImage, CheckptCf, UtilityC);
	return TargetC;
```

Step 2.1 is described [here](traditional%20migration.md), while 2.2 and 2.3 in their respective sections [of this page](stateful%20migration.md), where an example for step 5 is reported as well.

The important thing to notice is that all the pieces of information (image layers, volumes content and checkpoints) not already present at the destination are fetched from the source, while the cooperative migration algorithm will have, in general, multiple options.

Here is a possible implementation of steps 3 and 4 in shell scripting:
```
# 3. stop container and create checkpoint
ssh $SOURCE "docker checkpoint create $CONTAINER $CHECKPT_F --checkpoint-dir=\"$CHECKPT_DIR\""

# 4.1 send checkpoint difference
rsyncFrom $SOURCE "$CHECKPT_DIR/$CHECKPT_F/" "$CHECKPT_LOCAL/$CHECKPT_I"
mv "$CHECKPT_LOCAL/$CHECKPT_I" "$CHECKPT_LOCAL/$CHECKPT_F"

# 4.2 sync writable volumes content
while read name destination rw rest; do
	if [ $rw = "true" ]; then
		rsyncFrom $SOURCE "$BACKUP_DIR/$name.tar" "$TARGET_DIR"
	fi
done < "$VOL_LIST"
```
> Volumes' metadata is collected in a `$VOL_LIST` text file as in [this example](stateful%20migration.md#migrating-volume-mount-options).

Specifically, `rsyncFrom(node, src, dest)`, to keep the same structure used in the pseudo-code above, has its own function:
```
function rsyncFrom {
	if [ $# -ne 3 ]; then
		echo "Usage: $0 SOURCE SRC_PATH DEST_PATH"
		exit 1
	fi

	rsync -avz --delete $1:"$2" "$3"
}
```

The complete script can be found [here](../stateful%20migration/tsm_dest.sh).

> Note that `rsync` can also be used with non-archived volumes content, but with some additional complexity due to the isolation of containers file system from their host.

### Example ###
To test our script, we can try to migrate a toy container which has some running state (in RAM) and makes use of a writable volume, both periodically updated.

Set up:
1. Start a master node, a source and a destination
2. Run a [local Registry](../various/utils/local_registry.sh) on the master and pull/push a basic `busybox` image from the Docker Registry
   ```
   local_registry.sh <CERTS_DIR>
   docker pull busybox
   docker tag busybox <MASTER_ADDR>/busybox
   docker push <MASTER_ADDR>/busybox
   ```
3. Run the toy container at the source
   ```
   docker run -d --name toytsm \
		-v /myvol busybox /bin/sh \
		-c 'i=0; while true; do echo $i | tee -a /myvol/testfile; i=$((i+1)); sleep 1; done'
   ```

Now we can migrate it to the destination by executing:
```
tsm_dest.sh <SOURCE_ADDR> toytsm
```

In case of success, the script prints the ID of the migrated container. To check that runtime and storage data have actually been migrated to the destination, run:
```
docker logs <TARGET_CONTAINER> | head
# the counting should start from where it was interrupted at the source

docker exec -it <TARGET_CONTAINER> cat /myvol/testfile | head
# the file, however, should start from 0
```

### References ###
- [rsync](https://download.samba.org/pub/rsync/rsync.html)
- [How Rsync Works](https://rsync.samba.org/how-rsync-works.html)
