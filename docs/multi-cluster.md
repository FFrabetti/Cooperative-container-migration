# Multi-cluster #
We refer to _multi-cluster_ (or inter-cluster) _migration_ when source and destination are located in different clusters.
This has a number of consequences:

- Source and destination don't belong to the same network, are not aware of their respective IP addresses and do not communicate directly.
- The level of trust is limited and so is also the amount of information one cluster is willing to share externally.
- There may not be a central controller/coordinator. In this case, the two clusters have to treat each other as peers and agree on a set of interfaces and protocols.
- While intra-cluster communications are considered secure and normally very efficient in terms of latency and throughput, inter-cluster ones may experience a great variability of both due to shared/public channels in between, higher error rates, and so on.

Some simplifying assumptions need to be made to tackle the problem of multi-cluster migration:
- **Global names**: there is an agreement that allows nodes to reference entities (like layers, volumes, containers, applications, etc.) in a unique way across cluster boundaries. This may be done by using digests (for immutable content), low-collision GUIDs, domain names, or an external name system/authority.
- **Control messages**: some control messages are exchanged between "federated" clusters. The details of those, however, are beyond the scope of this project. Similarly, we do not deal with security issues, peer authentication and related problems.

## Multi-cluster migration ##

### Reference architecture ###
Considering a pair of clusters `ClusterA` and `ClusterB`, they can communicate (for what container migration is concerned) just through a **pair of proxies** that we call `ProxyAB` and `ProxyBA` respectively.
When a migration from node `S`, located in `ClusterA`, to node `D`, belonging to `ClusterB`, is required, `ProxyAB` assumes the role of `DestinationProxy` and `ProxyBA` the one of `SourceProxy`.

> The two proxies are logical entities and they can be located at any node, not necessarily a master.

The idea is that both `S` and `D` should not be aware of the fact that they belong to different clusters (let alone which ones), but they should believe their counterpart to actually be located in their own cluster, so that everything can be carried out, from their perspective, exactly as in a single cluster migration.
The source would therefore behave as the migrating container is destined to `DestinationProxy` (`ProxyAB`), while the destination would refer to `SourceProxy` (`ProxyBA`) as the source.

The two proxies would have to impersonate their respective roles by communicating with one another, transferring information in a controlled way between the two clusters.
The major problem is, therefore, how these proxies should work to make multi-cluster migration transparent to the rest of the nodes involved.

### Aggregated meta-data exchange ###
Each proxy communicates to its peers aggregated information about its cluster: specifically, we are interested in what entities can be found and the (minimum) "cost" of retrieving them.

> The "cost" is an indicator of the quality of the source-to-destination/E2E channel and it serves the purpose of deciding where to fetch a given content from. By using this abstraction, a policy may simply choose the node that can provide the content with minimum cost, without requiring a cluster to expose its internal details.

> Each proxy would know the cost of getting the content from the nodes that have it in its own cluster, therefore the "E2E cost" would be the _minimum of those_ plus the (estimated) _cost_ related to the _channel between the two proxies_.

From the point of view of a cluster-level registry (regardless of it dealing with layers, volumes or checkpoints), the proxy behaves exactly as any other node, advertising which pieces of content it has - i.e. the ones available at its corresponding remote cluster - and the cost of each of them.

### Migration steps ###
When a multi-cluster migration request is issued (from the source cluster), we can imagine that some control messages are exchanged by the two proxies to agree on it.
A reasonable exchange could be something like this:
- `DestinationProxy`: can I migrate the container `C`?
- `SourceProxy`: (after checking if enough resources are available) ok

They would then be in charge of issuing the migration request within their respective clusters. The receiving side would have to **decide which node would be the destination**: this information does not need to be propagated to the source, which believes the destination to be `DestinationProxy`. Similarly, the destination cluster has no knowledge of the actual source node.

1. A migration is agreed for a given container from `ClusterA` (node `S`) to `ClusterB` (node `D`)
   - On `ClusterA`: a migration request is issued from `S` to `ProxyAB`, as `DestinationProxy`
   - On `ClusterB`: a migration request is issued from `ProxyBA`, as `SourceProxy`, to `D`

The other steps depend on the type of migration, but they are substantially similar to the ones described for single cluster stateless and stateful migration.
The following pages focus therefore on the tasks of the two proxies and their implementation:

- [Multi-cluster stateless migration](multi-cluster_stateless.md)
- [Multi-cluster stateful migration](multi-cluster_stateful.md)

## Network topology ##
If all entities are executed as Docker applications (i.e. within a container), clusters can be identified by dedicated [overlay networks](https://docs.docker.com/network/overlay/). Similarly, an additional overlay network comprising the two proxies may be used for inter-cluster communications (its traffic may be encrypted at the price of additional overhead).

Overlay networks allow communications between containers running on different Docker daemon hosts, with automatic DNS discovery (using unique container names) and exposure of ports just within the overlay network.

See: [config_cluster.sh](../multi-cluster/config_cluster.sh)
