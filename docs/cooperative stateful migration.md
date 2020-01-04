# Cooperative stateful migration #
With respect to [traditional stateful migration](traditional%20stateful%20migration.md), we have to describe how each piece of data may be cooperatively transferred to the destination.

### Read-only data: addressable content ###
We have already seen for stateless migration how to fetch container image layers in a cooperative way. A similar concept can also be applied to read-only volumes: we just need a way to know which volumes the migrating container requires (content addressability) and which ones are present at the destination neighboring nodes (and at the destination itself).

A simple implementation can use a hash function to create a low-collision digest that identifies each volume, to be stored in a registry-like data structure for querying: `DIGEST -> [NODE_1, ..., NODE_N]`.

> We are using "volumes" here to refer to the volumes content. Volumes meta-data does not change over time and it is generally a few bytes, so it can be retrieved from the source as read-only data with minimum overhead.

### Writable data: cached snapshots ###
For writable volumes there would be no point in checking their presence in neighboring nodes: as we expect their content to change over time, if the frequency of write operations is sufficiently higher than migration frequency (which is normally the case), the chance of finding the _exact_ same content somewhere else besides the source is negligible.

To increase our chances, we can however relax the "equality" constraint and use something else that gives us a reasonable estimate of the "similarity" between two contents. The simplest idea is to associate each volume to a globally unique ID, not related to its content, and periodically save a snapshot of it with its corresponding timestamp: when looking for a volume, the destination may then choose among a list of nodes that have a previous snapshot of the volume content (same GUID), with a policy that could take into account the "freshness" of data (preferring recent timestamps) and the "goodness" of the channel (plus, eventually, nodes current load, etc.).

In a similar way to what happens with cooperative stateless migration, also in this case the obvious fallback is getting the content from the source, which would certainly have the most updated version, but which may not be the best option overall.

Using cached snapshots of user data is mainly intended for high-variability contexts (generally due to user mobility), where the same user-service may be migrated multiple times in order to meet strict QoS requirements as network conditions change. At some point, a migration may target an edge node already visited in the past, or one which is neighboring others as such: in those cases, previously stored ("cached") snapshots may come in handy to fetch the required pieces of data from multiple sources.

This idea of cached snapshots can be applied to writable volumes and to memory checkpoints as well, in the scope of the second step detailed [here](traditional%20stateful%20migration.md), while the data from step 4 must necessarily come from the source.

A design choice is the period of checkpointing (which may depend on write frequency) and what to do with old snapshots, as it is reasonable to provide a way of discarding cached data after some time.

#### Taking one step further ####
As previously stated, the original idea was to estimate when two contents were similar, which is a reasonable assumption for "recent" (or "close in time") versions with the same GUID, but this is not the only case; another easy condition to test is if they represent the same _logical entity_, but for different instances/users. Again, this applies to volumes content and to checkpoints as well.

Imagine a writable volume with a lot of data, but with only a small fraction of it being user-dependent (or changing frequently, or _not_ common to any other user): instead of transferring it from the source at step 2, it may come from a different node that has the same _logical_ volume because another user is using the same type of containerized application.

The advantage for memory snapshots is similar: many applications in "idle" state (not actively performing a task/serving a request) do not store a great amount of user data in memory, so any snapshots of the same application may be quite similar to the one of the migrating service.

To keep things simple, we assume that volumes are just compared with their previous snapshots, while checkpointed containers also with others of the same kind (i.e. hosting the same service).
This assumption comes from the fact that a good practice would be to use shared volumes for common data and "dedicated" writable volumes just for the data that is actually specific to that particular user.

From the implementation point of view, containers started from the same image are considered for fetching memory checkpoints:
- previous checkpoints of the same container _(and user)_ are assigned a value based on their timestamp (and channel conditions)
- checkpoints of containers of the same logical service _(but different user)_ are assigned an arbitrary value (again dependent on channel conditions)

These values allow the fetching policy to choose among the different options provided by various neighboring nodes.

## Script ##

### Example ###
