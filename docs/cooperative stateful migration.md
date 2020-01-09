# Cooperative stateful migration #
With respect to [traditional stateful migration](traditional%20stateful%20migration.md), we have to describe how each piece of data may be cooperatively transferred to the destination.

### Read-only data: addressable content ###
We have already seen for stateless migration how to fetch container image layers in a cooperative way. A similar concept can also be applied to read-only volumes: we just need a way to know which volumes the migrating container requires (content addressability) and which ones are present at the destination neighboring nodes (and at the destination itself).

A simple implementation can use a hash function to create a low-collision digest that identifies each volume, to be stored in a registry-like data structure for querying: `DIGEST -> [NODE_1, ..., NODE_N]`.

> We are using "volumes" here to refer to volumes content. Volumes meta-data does not change over time and it is generally a few bytes, so it can be retrieved from the source as read-only data with minimum overhead.

### Writable data: cached snapshots ###
For writable volumes there would be no point in checking their presence in neighboring nodes: as their content is mutable, if the frequency of write operations is sufficiently higher than migration frequency (which is normally the case), the chance of finding the _exact_ same content somewhere else besides the source is negligible.

To increase our chances, we can however relax the "equality" constraint and use something else that gives us a reasonable estimate of the _similarity_ between two contents. The simplest idea is to associate each volume to a globally unique ID, not related to its content, and periodically save a snapshot of it with its corresponding timestamp: when looking for a volume, the destination may then choose among a list of nodes that have a previous snapshot of the volume content (same GUID), with a policy that could take into account the "freshness" of data (preferring recent timestamps) and the "goodness" of the channel (plus, optionally, nodes current load, etc.).

In a similar way to what happens with cooperative stateless migration, also in this case the obvious fallback is getting the content from the source, which would certainly have the most updated version, but which may not be the best option overall.

Using cached snapshots of user data is mainly intended for high-variability contexts (generally due to user mobility), where the same user-service may be migrated multiple times in order to meet strict QoS requirements as network conditions change. At some point, a migration may target an edge node already visited in the past, or one which is neighboring others as such: in those cases, previously stored ("cached") snapshots allow to fetch the required pieces of data from multiple sources.

This idea of cached snapshots can be applied to writable volumes and to memory checkpoints as well, in the scope of the second step detailed [here](traditional%20stateful%20migration.md), while the data from step 4 must necessarily come from the source.

#### Taking one step further ####
As previously stated, the idea is to estimate when two contents are similar, which is a reasonable assumption for "recent" (close in time) versions with the same GUID, but this is not the only case: another easy condition to test is if they represent the same _logical entity_, but for different instances/users. Again, this applies to volumes content and to checkpoints as well.

Imagine a writable volume with a lot of data, but with only a small fraction of it being user-dependent (or changing frequently, or _not_ common to any other user): instead of transferring it from the source at step 2, it may come from a different node that has the same _logical_ volume because another user is using the same type of containerized application.

The advantage for memory snapshots is similar: many applications in "idle" state (not actively performing a task/serving a request) do not store a great amount of user data in memory, so any snapshots of the same application may be quite similar to the one of the migrating service.

To keep things simple, we assume that writable volumes are just compared with their previous snapshots, while checkpointed containers also with others of the same kind (i.e. hosting the same service).
This assumption comes from the fact that a good practice would be to use shared volumes for common data and "dedicated" writable volumes just for data specific to a particular user.

From the implementation point of view, **containers started from the same image tag** are considered for fetching memory checkpoints.

## Implementation ##

### Addressable read-only volumes ###
Once we have a way to compare two contents (e.g. through their digest), we just need a mechanism to store and retrieve, given a content ID/digest, a list of nodes that content can be fetched from.
The problem of choosing among them, for example by testing the condition of the channel or the current workload of the node - i.e. by applying a certain _policy_ -, should be treated separately.

What we have described is actually a **hash-map**, whose key is a content identifier and the stored value is a list of nodes.
A simple way to implement it is by using [Redis Sorted sets](https://redis.io/topics/data-types-intro#redis-sorted-sets): Redis keys can be basically anything (up to 512 MB), and the stored value can be a data structure like a sorted set, an ordered collection of (string) elements without replication.

In our case, it is useful to have non-repeated values by design, so we don't have to worry about checking if a node IP is already present or not before adding it to the set.
The ordering of elements can come in handy if we want to store, together with each IP, an indicator of the _quality_ of the location (score or rank in Redis terminology). Any score can be updated at a later time and the set re-ordered accordingly.

> Storing a score is not deciding where to get the content from: it can be seen as a "registry-side, loosely updated indication", for example encapsulating hardware differences (prefer the most performant machine) or certain known topological conditions (prefer the node which is normally less loaded).
> The fetching policy is still in control of the decision, so it is free to ignore score values completely or, for example, to request just the top 5 nodes in the set and then choose among them.

The commands we need are:
- ZADD: add members or update their score (ZREM the remove them)
- ZCARD: get the number of elements
- ZRANGE, ZRANGEBYSCORE (ZREVRANGE, ZREVRANGEBYSCORE): return a sorted range of members delimited by index or by score (default: increasing score)
- ZSCAN: iterate over the sorted set
- ZSCORE: get the score of a member

see: [Sorted Sets - Command reference](https://redis.io/commands#sorted_set)

> Additionally, Redis allows to perform all sorts of operations with sets, including intersection, union and set expiration timeouts on keys.

#### Fetching read-only volumes ####
All read-only data is transferred just once before the source container is stopped ([see migration steps](traditional%20stateful%20migration.md)). Differently from what happens with traditional migration, however, it can come from multiple sources.
The high-level algorithm can therefore be summarized as follows:

```
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

# 2.2.1 fetch read-only volumes
foreach ROVol in SendVolContentList:
	if ROVol.Readonly = true:
		N := selectNeighborWithVol(ROVol, ROPolicy);
		sendFrom(N, ROVol);
# 2.2.2 fetch writable volumes
...
```

An implementation of `selectNeighborWithVol` is given below in bash, with a basic policy that simply takes the highest score result:
```
function selectNeighborWithVol { # policy: highest score
	[ $# -eq 2 ] && { local RHOST="-h $1"; shift; }
	local KEY="$1"
	
	redis-cli --raw ${RHOST:-} ZREVRANGE "$KEY" 0 0 	# <- START STOP (inclusive)
}
```

#### Updating the volumes registry ####
Whenever a node acquires new read-only volumes (e.g. because of incoming migrations), it has to update the registry.

```
function updateVolRegistry {
	[ $# -eq 4 ] && { local RHOST="-h $1"; shift; }
	local KEY="$1"
	local VALUE="$2"
	local SCORE=$3
	
	redis-cli --raw ${RHOST:-} ZADD "$KEY" $SCORE "$VALUE"
}
```

### Writable dedicated volumes ###
Because of the assumption introduced in the previous sections, writable volumes content is strictly associated with a specific user, therefore we may obtain a previous version of it just from a past migration of the same service/container.

Each volume has a GUID from which it can be identified across the cluster and over changes of its content, i.e. different versions: each version is defined by the volume's GUID and a timestamp; because the same containerized service is never executed on multiple nodes at the same time, this couple uniquely identifies a volume version.

Again, a simple way to implement this data structure is by exploiting Redis Sorted sets with timestamp as ranking criterion.
Here a revisited version of the pseudo-code from above:
```
# 2.2.1/2 fetch volumes content
foreach Vol in SendVolContentList:
	if Vol.Readonly = true:
		N := selectNeighborWithVol(Vol, ROPolicy);
		sendFrom(N, Vol);
	else
		N := selectNeighborWithVol(Vol, RWPolicy);
		sendFrom(N, Vol);
```

#### Updating the volumes registry ####
Writable volumes content change over time, but just when it is mounted to a running container in the current node. For this reason, we can limit registry updates (and caching of content snapshots) just after each migration.

The update mechanism is the same seen for read-only volumes, with the only difference in how the GUID is generated and in the additional timestamp associated with each version.

> Another, minor, difference would be the policy used for invalidating/discarding old volume snapshots after some time: in general, as they belong to a specific user, their lifespan may be shorter than the one of sharable read-only volumes.

### Memory checkpoints ###
With memory checkpoints the idea is to use a combination of the two methods described above for different kinds of volumes: on one side previous snapshots of the same service are cached at intermediate nodes after migration (intermediate if considering multiple migrations), while at the same time _checkpoints of **other containers** hosting the **same logical service**_ are also taken into consideration when fetching the content before stopping the container at the source.

To sum up, checkpoints are as sharable as read-only volumes, but they also have versions ranked by their timestamp as writable volumes.

When fetching a checkpoint, I want to refer to it by its application for the assumption of having similar memory fingerprints to apply. We therefore **associate each container image tag to a specific application/logical service**.

> This is not a significant limitation, considering that version tags can be used to differentiate between applications started from the same image (as an image can have multiple tags).

#### Fetching checkpoints ####
The checkpoints registry should allow this kind of basic queries: `IMAGE_TAG -> [NODE_1, ..., NODE_N]`, plus, for previous versions of the same service: `(IMAGE_TAG, USER_ID) -> [(TIMESTAMP_1, NODE_1), ..., (TIMESTAMP_M, NODE_M)]`.

There may be different ways of implementing this behavior, but an easy one is to re-use the same Redis Sorted set concept used so far:
- `IMAGE_TAG` is the key of a Sorted set where `NODE_K`s members are ranked with some _quality_ score
- `(IMAGE_TAG, USER_ID)` together they form a `SERVICE_GUID`, which is the key of another Sorted set of nodes ranked by version timestamp

This is an implementation of a function for selecting the node with the most recent checkpoint of the same service/container or, in case there is none, the one with the highest score among cached checkpoints of the same application (if even this set is empty, the fallback is retrieving it from the source): 

```
function selectNeighborWithCheckpt {
	[ $# -eq 3 ] && { local RHOST="-h $1"; shift; }
	local IMAGE_TAG="$1"
	local USER_ID="$2"
	
	local RES=$(redis-cli --raw ${RHOST:-} ZREVRANGE "$IMAGE_TAG:$USER_ID" 0 0)
	if [ $RES ]; then
		echo $RES
	else
		redis-cli --raw ${RHOST:-} ZREVRANGE "$IMAGE_TAG" 0 0
	fi
}
```

In general, it is up to the chosen policy how the retrieved values are used to decide where to fetch checkpoints from.

#### Updating the checkpoints registry ####
The `IMAGE_TAG` set needs to be updated for every incoming migration, while for outcoming ones a new checkpoint version needs to be added to the `SERVICE_GUID` set together with its timestamp.

> If the same node is visited more than once through a series of migrations, the timestamp value would simply be updated, which is coherent with the expected behavior.

```
function updateCheckptRegistry {
	[ $# -eq 5 ] && { local RHOST="-h $1"; shift; }
	local IMAGE_TAG="$1"
	if [ $# -eq 4 ] && [ ! "$2" = "" ]; then
		local KEY=":$2" 	# :$USER_ID
		shift
	fi
	local VALUE="$2"
	local SCORE=$3
	
	redis-cli --raw ${RHOST:-} ZADD "$IMAGE_TAG${KEY:-}" $SCORE "$VALUE"
}
```

##### Implementation final notes #####
From [ZADD – Redis](https://redis.io/commands/zadd):
> The score values should be the string representation of a double precision floating point number. `+inf` and `-inf` values are valid values as well.

See also: [redis-cli, the Redis command line interface](https://redis.io/topics/rediscli)

## Script ##
The 5 steps described for [traditional stateful migration](traditional%20stateful%20migration.md) apply to cooperative migration as well, with the difference that multiple sources can provide different bits of information. Because of that, some parts may be parallelized: specifically, tasks that are in the same step can be executed concurrently.

To give an idea, in pseudo-code ("bash-like") it would be something like this:
```
# 2. get all container data
fetchLayers 	...args... & PID1=$!
fetchVolumes	...args... & PID2=$!
fetchCheckpt	...args... & PID3=$!

wait 	# or: wait $PID1 $PID2 $PID3
```
For layers and volumes, each of them can also be transferred in parallel.

We have already explained in previous sections how the destination can find out and choose where to get each piece of content from, so here we simply report the corresponding snippets in bash script for step 2:

```
function fetchVolume {
	local name="$1"
	local prefix="$2"
	local guid="$3"

	local neighbor=$(selectNeighborWithVol "$REDIS_HOST" "${prefix}:${guid}")
	[ $neighbor ] && scp $neighbor:"$VOL_ARCHIVES/${prefix}.${guid}.tar" "$VOL_BACKUPS/$name.tar"
}

function fetchCheckpt {
	local image_tag="$1"
	local user_id="$2"
	
	local neighbor=$(selectNeighborWithCheckpt "$REDIS_HOST" "$image_tag" "$user_id")
	[ $neighbor ] && scp $neighbor:"$CHECKPT_ARCHIVES/$image_tag.tar" ./
}
```

```
# 2.2 transfer volumes
ssh $SOURCE "$REMOTE_SH_DIR/get_volumes_list.sh $CONTAINER" > "$VOL_LIST"

mkdir "$VOL_BACKUPS"
while read name destination rw labels options; do
	if [ $rw = "true" ]; then
		echo $name "$destination"
		
		rw_guid=$(get_label_value "$RW_GUID_KEY" "$labels")
		archpath="$VOL_ARCHIVES/rw.${rw_guid}.tar"
		[ $rw_guid ] || error_exit "Writable volume $name has no GUID"
		if [ -e "$archpath" ]; then
			cp "$archpath" "$VOL_BACKUPS/$name.tar"
		else
			fetchVolume "$name" "rw" "$rw_guid" & 	# background
		fi
	else
		ro_guid=$(b64url_encode "$IMAGE$destination")
		archpath="$VOL_ARCHIVES/ro.${ro_guid}.tar"
		if [ -e "$archpath" ]; then
			cp "$archpath" "$VOL_BACKUPS/$name.tar"
		else
			if volumeSetNotEmpty "$name" "ro" "$ro_guid"; then
				fetchVolume "$name" "ro" "$ro_guid" & 	# background
			else
				echo $name "$destination" 	# ro volumes not in any $VOL_ARCHIVES
			fi
		fi
	fi
done < "$VOL_LIST" | ssh $SOURCE "$REMOTE_SH_DIR/run_utilc_voltotar.sh $CONTAINER $REMOTE_VOL_BACKUPS"

wait
rsyncFrom $SOURCE "$REMOTE_VOL_BACKUPS/" "$VOL_BACKUPS"
```

```
# 2.3 transfer checkpoint
mkdir -p "$CHECKPT_DIR"
fetchCheckpt "$IMAGE" "$USER_ID" && tar xf "$IMAGE.tar" -C "$CHECKPT_DIR"

CHECKPOINT=$(date +%F_%H-%M-%S)
ssh $SOURCE "docker checkpoint create $CONTAINER $CHECKPOINT --checkpoint-dir=\"$REMOTE_CHECKPT_DIR\" --leave-running"
rsyncFrom $SOURCE "$REMOTE_CHECKPT_DIR/$CHECKPOINT/" "$CHECKPT_DIR" "-acz --delete"
```
([See full script](../stateful%20migration/csm_dest.sh))

### Example ###
The same toy application presented for traditional migration is suitable for the cooperative approach as well, given some adjustments.

One major difference is in the setup process: we need the destination to be able to query a Redis server about volumes and checkpoints (plus a Docker Registry for layers), and, to see cooperation in practice, we need at least one other node to get those contents from.
For this first example, all these elements will be hosted on the master.

#### Master setup ####

##### Docker Registry #####
TODO

##### Redis server #####
1. Start a Redis instance:

   ```
   docker run -d -p 6379:6379 --name myredis redis
   ```
2. Install `redis-cli` and test if the server is reachable:
   
   ```
   sudo apt-get install redis-tools
   redis-cli ping || echo "Error: cannot ping the server"
   ```

##### Volumes and checkpoints #####
We want the master to have:
- a copy of the read-only volume `testro`
- a snapshot of the writable volume `testrw`
- a checkpoint of our `toytsm` container

(see [the previous example](traditional%20stateful%20migration.md#example))

All of them must also be correctly registered in the Redis server for querying.

Because of the complexity of the setup process, these stages have been grouped in a script: [csm_example_master.sh](../stateful%20migration/csm_example_master.sh)

```
csm_example_master.sh <SOURCE> <MASTER> <USER_ID>
```

#### Source & Destination setup ####
At the source, the migrating container has to be running (check with `docker container ls | grep toytsm`).

The destination needs to have its own local Registry and, for the sake of this experiment, it should also have an empty `VOL_ARCHIVES`:
```
ls -l /volume_archives
sudo rm -ri /volume_archives
```

## From centralized to distributed ##
Up to now, we have implicitly assumed the presence of a Docker Registry and of a Redis instance with volumes and checkpoints "registries" every node could refer to for queries and updates.
Within a single cluster, those can reasonably be located at a master node, performing coordination and orchestration tasks in a centralized way. In large clusters or in multi-cluster scenarios, however, some issues arise from the problem of managing neighborhoods and "local" data in a scalable way.

A viable solution may be to partition and replicate the information once stored at the master on every single node, moving towards a decentralized scenario where control is distributed among peers.
Every node would have its own local registries it can query about image layers, volumes and checkpoints _in its neighborhood_, without requiring the intervention of a mediator. While the reading side seems perfectly fine, the writing side has some problems, as nodes would have to keep updating all their neighbors of every change.

This problem can be mitigated with a public/subscribe approach based on notification events: for every change regarding node N, an event is published to its respective topic and all subscribers (N's neighbors) get notified by the messaging system.

An easy way of implementing this mechanism is by exploiting [Redis Pub/Sub](https://redis.io/topics/pubsub) on each node's local Redis instance, but the management of control messages is a whole problem on its own and it is out of the scope of this work to address it.

#### Redis Pub/Sub example ####
Subscriber:
```
stdbuf -oL redis-cli -h "$REDIS_HOST" --raw SUBSCRIBE "$CHANNEL" | while read line; do
	echo "$line"
	# do some processing...
done
```
(Example with CSV format: [redis-sub.sh](../stateful%20migration/redis-sub.sh))

Publisher:
```
redis-cli -h "$REDIS_HOST" PUBLISH "$CHANNEL" "$MESSAGE"
```
