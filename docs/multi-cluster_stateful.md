# Multi-cluster stateful migration #

Besides container layers, volumes and checkpoints may be fetched from remote clusters as well, in a similar fashion to what we have seen for multi-cluster stateless migration.
In addition to that, which we can classify as the problem of retrieving/fetching a content/file from a remote location, we also have to deal with:
- Remote synchronization: when we want to transfer just the difference with respect to what we already have
- RPC: when we want to execute some tasks remotely, like stopping the source container and creating a checkpoint

> We are using "remote" as synonym of "inter-cluster".

### Content fetching ###

One of our assumptions is that we can identify each piece of content in a unique way across federated clusters, i.e. we are using either _addressable content_ (for layers and read-only volumes) or global names.

With this assumption, when the destination asks `SourceProxy` for a specific content, the latter simply has to forward the request to its peer, which takes the matter of getting the content from anywhere within its own cluster as a "normal" destination would do (consulting a registry first, etc.).

Note that in the worst case, if no local cache is available at the two proxies, fetching remote content requires two queries to the registry instead of one as for the same content retrieved from within the destination cluster. This overhead may be expressed as part of the additional "cost" associated with the remote instance of the content.

### Remote synchronization ###

Before stopping the container at the source, we want to make sure that the destination has up-to-date information about writable volumes and runtime state, so that just the most recent changes are left for the following step, which takes place during service downtime.
In cooperative migration we do this by synchronizing the content from the source with what the destination was able to fetch from other neighboring nodes.
A second synchronization takes place after the container is stopped, as the last step of our simplified pre-copy.

In a multi-cluster scenario, `DestinationProxy` acts as a "traditional" destination, requesting the entire content directly from the source, while the synchronization is performed by `SourceProxy` (which has direct knowledge of both endpoints) between `DestinationProxy` and the destination. This solution allows to keep the entire procedure simple (as `DestinationProxy` doesn't fetch the content from multiple sources first) while also limiting the amount of data transferred across clusters (with the assumption that inter-cluster channels are worse than intra-cluster ones).

### Remote Procedure Call ###

Not differently from the case of content fetching, executing tasks in a remote cluster may be done by using the two proxies for forwarding the request in one direction and the response in the other.

> To make the forwarding more evident, the proxies can even use different APIs to communicate with one another.

The simplification here is that each RPC is perfectly synchronous, so the caller waits for the task to be completed, which can be optimized with an asynchronous behaviour whenever `DestinationProxy` can actually replace the destination in an active role.
For example, it may require the source to create archives with the updated content of all its writable layers, as they are certainly going to be requested, or to take a snapshot even before the request arrives from the destination.

A key point here is again being able to address entities across clusters. We have already stated how this is possible for layers and volumes, but not for containers: how does the destination refer to the source container and how does `SourceProxy` know where/in which node the container is located?

The idea is to use global names for containers as we did for writable volumes: when the multi-cluster migration request is "divided" into two migrations (source to `DestinationProxy` and `SourceProxy` to destination), a _common container name_ (CCN) is chosen as an alias to identify the source container in a unique way: when a RPC arrives at `DestinationProxy` for a given CCN, it translates it into a `(source, container)` pair using a lookup table.

## Implementation ##

### SourceProxy ###

### DestinationProxy ###

### Metadata off-line exchange ###

## Example ##

### Setup ###
