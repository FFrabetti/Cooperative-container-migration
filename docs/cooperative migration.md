# Cooperative migration #
In a cooperative migration, the destination can exploit other neighboring nodes besides the source to reconstruct the migrating container.

For stateless migration, this means being able to retrieve the container image layers from multiple sources, i.e. from any node that has a copy of them.

Basic assumptions and topology are the same reported for [traditional migration](traditional%20migration.md).

#### Pre-requisites ####
- The destination has to know which layers are present in all its neighbors*
- In order to efficiently fetch the required layers, the destination should also have information about:
  - Its neighbors’ current workload
  - Each channel current status (traffic/bandwidth, latency, …)
  
  These parameters can be exploited by the policy used to decide among multiple possible candidates providing a given layer (one is always the source node).

For now, we consider just the first point.

> \* in this context, B is neighbor of A if A can fetch layers from B (it may not be true the other way around). A and B do not have to be at single-hop distance.

#### Scenarios ####
- **Centralized knowledge base**
  - [Pull-based](#pull-approach)
  - [Push-based](#push-approach)
- **Destination-side Pull**: with [on-line queries](#pull-on-line-queries) or via [periodic requests](#pull-periodic-requests) (off-line)
- **[Off-line Push](#off-line-push)**: notification events and periodic updates

## Centralized knowledge base ##
A service running on the master can be queried by-need (**on-line**) to get information about nodes and layers (cluster-level knowledge base). We call this service _ClusterKB_.

ClusterKB itself can obtain the information **off-line**, following a pull or push approach.

#### Steps ####
Because we introduced a third entity in the picture, from the point of view of the destination the logical steps are very similar to the ones of the [layered custom client scenario](traditional%20migration.md#layered-custom-client), with these slight variations:

3. The destination downloads just the layers it needs (**GET**)
   1. The list of layers is obtained from ClusterKB, together with, for each layer, the nodes that have a copy of it
   2. _\[unchanged]_
   3. The layers are fetched from various nodes, not just from the source

### Pull approach ###
ClusterKB periodically queries all nodes to get the list of layers they manage, keeping a cluster-local data structure updated.

When a migration request is issued, the destination can retrieve the information about the nodes having a copy of the image layers from ClusterKB. The information will be readily available, but it will be based on the last update, i.e. at most as old as the pull period.

#### Script ####
...

### Push approach ###
ClusterKB listens to periodic updates sent by each node and to notification events emitted when there is a change in a node's Registry.

Because events - the information content of which is just an incremental difference - can be lost if there is no-one ready to listen to them (for example because of a full queue at the receiver side), periodic updates are sent with the entire information to compensate the loss of any previous events.
Ideally, with no event loss and timely delivery, the cluster-level knowledge base is always updated with fresh data.

#### Script ####
Nothing changes for the destination, but ...

## Destination-side Pull ##
If we get rid of ClusterKB, the destination itself may implement a pull approach by requesting its neighbors to send the list of layers they have. This can be done either on-line, when the migration request is issued, or off-line, by periodically querying them.

### Pull: on-line queries ###
Greater overhead but simpler implementation. Fresh data.

### Pull: periodic requests ###
No overhead (off-line) but more difficult to implement.

## Off-line Push ##
The alternative for the destination is to listen to events emitted by its neighbors, so to have a local knowledge of their layers always updated. Similarly to the [centralized push approach](#push-approach), periodic updates are also sent even when there are no changes to the node's Registry.

No overhead (off-line) and fresh data, but it may require an event broker to handle all notifications.
