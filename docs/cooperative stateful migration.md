# Cooperative stateful migration #
In [this page](stateful%20migration.md) we have broken down the problem of migrating service state within containerized applications. The proposed methods have to be contextualized in the actual case of a container being migrated to a different node in a stateful way.

***We are considering the simplifying assumption of just one user per container.***

The migration process, at high level, can be summarized as follows:
1. A migration request is issued
2. Some container data is sent to the destination
3. The source container is stopped
4. The remaining data is transferred to the destination
5. A new container is started at the destination

In order for the migration to be as short as possible (thus reducing some QoS parameters of interest not reported here), steps 2 and 4 have to be short and efficiently performed.

> They are the steps involving other nodes, so they can be optimized by changing the type of migration from "traditional" to cooperative.

Intuitively, when a migration request is issued it means that the QoS provided by the current edge node is below a given threshold, so we have all the interest in migrating the service to a (better) target node as quickly as possible, if it can provide the required QoS.
Additionally, between steps 3 and 5 there is a period of service downtime, so keeping it small contributes to the effect of providing a seamless service migration.

> Pre-copy, post-copy or other hybrid migration techniques are out of the scope of this work, which is to evaluate the performance improvement of cooperative migration with respect to "traditional" migration, regardless of the migration technique used by the both of them.

## Traditional stateful migration ##
While in stateless migration we could start a new container at the destination _before_ stopping the one at the source, so to avoid any downtime, in the case of stateful migration this is not possible because of the state changes made _during_ the migration process. This very problem is the same of pre-copy: at some point the source service must be stopped so that the last incremental changes can be migrated to the destination without experiencing any _other_ changes in the meantime.

To keep things simple, all read-only data is transferred before step 3, leaving writable data for step 4.

We can therefore further detail the steps of migration:
1. A migration request is issued
2. Container data is sent from the source to the destination
   - Container image
   - Read-only volumes _and writable volumes_
   - _A snapshot of the running container_
3. The source container is stopped
4. Writable data is transferred to the destination
   - Writable volumes (`rsync`)
   - The checkpointed source container (`rsync`)
5. A new container is started at the destination

> The Container layer is not migrated, to avoid unnecessary additional complexity.

Note that in step 2 not just read-only data is sent to the destination. This is done to implement a very simple **one-iteration pre-copy migration**, so to send in step 4 just those pieces of writable data that have been changed.

To do so, we are using `rsync`...

### Script ###

## Cooperative stateful migration ##
With respect to traditional migration, we have to describe how each piece of data may be cooperatively transferred to the destination.

### Read-only data: addressable content ###
We have already seen for stateless migration how to fetch container image layers in a cooperative way. A similar concept can also be applied to read-only volumes: we just need a way to know which volumes the migrating container requires (content addressability) and which ones are present at the destination neighboring nodes (and at the destination itself).

A simple implementation can use a hash function to create a low-collision digest that identifies each volume, to be stored in a registry-like data structure for querying: `DIGEST -> [NODE_1, ..., NODE_N]`.

> We are using "volumes" here to refer to the volumes content. Volumes meta-data does not change over time and it is generally a few bytes, so it can be retrieved from the source as read-only data with minimum overhead.

### Writable data: cached snapshots ###
For writable volumes there would be no point in checking their presence in neighboring nodes: as we expect their content to change over time, if the frequency of write operations is sufficiently higher than migration frequency (which is normally the case), the chance of finding the _exact_ same content somewhere else besides the source is negligible.

To increase our chances, we can however relax the "equality" constraint and use something else that gives us a reasonable estimate of the "similarity" between two contents. The simplest idea is to associate each volume to a unique ID not related to its content and periodically save a snapshot of it with its corresponding timestamp.
When looking for a volume, the destination may then choose among a list of nodes that have a previous snapshot of the volume content (same ID), with a policy that could take into account the "freshness" of data (preferring recent timestamps) and the "goodness" of the channel (plus, eventually, nodes current load, etc.).

In a similar way to what happens with cooperative stateless migration, also in this case the obvious fallback is getting the content from the source, which would certainly have the most updated version, but which may not be the best option overall.

This idea can be applied to both writable volumes and to memory checkpoints as well, in the scope of the second step detailed above, while the data from step 4 must necessarily come from the source.

A design choice is the period of checkpointing (which may depend on write frequency) and what to do with old snapshots, as it is reasonable to provide a way of discarding cached data after some time (here as well there is room for sophisticated policies).

### Script ###
