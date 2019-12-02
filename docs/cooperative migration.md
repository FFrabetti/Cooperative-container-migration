# Cooperative migration #
In a cooperative migration, the destination can exploit other neighboring nodes besides the source to reconstruct the migrating container.

For stateless migration, this means being able to retrieve the container image layers from multiple sources, i.e. from any node that has a copy of them.

Basic assumptions and topology are the same reported for [traditional migration](traditional%20migration.md).

#### Pre-requisites ####
- The destination has to know which layers are present in all its neighbors*
- In order to efficiently fetch the required layers, the destination should also have information about:
  - Its neighbors’ current workload
  - Each channel current status (traffic/bandwidth, latency, …)
  
  A selection policy can use these parameters to decide among multiple possible candidates providing a given layer (one is always the source node).

For now, we consider just the first point.

> \* in this context, B is neighbor of A if A can fetch layers from B (it may not be true the other way around). A and B do not have to be at single-hop distance.

#### Scenarios ####
- **Centralized knowledge base**
  - [Pull-based approach](#pull-based-approach)
  - [Push-based approach](#push-based-approach)
- **Destination-side Pull**: with [on-line queries](#pull-on-line-queries) or via [periodic requests](#pull-periodic-requests) (off-line)
- **[Off-line Push](#off-line-push)**: notification events and periodic updates

## Centralized knowledge base ##
A service running on the master node can be queried by-need (**on-line**) to get information about nodes and layers (cluster-level knowledge base). We call this service _ClusterKB_.

ClusterKB itself can obtain the information **off-line**, following a _pull_ or _push_ approach.

#### Steps ####
Because we introduced a third entity in the picture, from the point of view of the destination the logical steps are very similar to the ones of the [layered custom client scenario](traditional%20migration.md#layered-custom-client), with these slight variations:

3. The destination downloads just the layers it needs (**GET**)
   1. The list of layers is obtained from ClusterKB, together with, for each layer, the nodes that have a copy of it
   2. _\[unchanged]_
   3. Layers are fetched from various nodes, not just from the source (according to a certain policy)

### Pull-based approach ###
ClusterKB periodically queries all nodes to get the list of layers they manage, keeping a cluster-local data structure updated.

When a migration request is issued, the destination can retrieve the information about the nodes having a copy of the image layers from ClusterKB. The information will be readily available, but it will be based on the last update, i.e. at most as old as the pull period.

#### Script ####
One script, to be executed at the master node, takes care of periodically pulling the information about layers availability within the cluster.
The implementation can be found [here](../cooperative%20migration/cpull_migr_master.sh).

At least 4 arguments are required:
- `REGISTRY`: the local Registry used to maintain the locations of each layer (in the form of an array of URLs)
- `PERIOD`: the period of the pulling cycle
- `WORK_DIR`: a directory where temporary files can be stored for ease of implementation (read below)
- `NODES`: the list of nodes belonging to the cluster, the targets of the pull requests

Every `PERIOD` seconds a series of GET requests are performed to `NODES`, obtaining the list of repositories, tags (images) and, ultimately, layers they currently manage.
In `WORK_DIR`, a separate file for each layer/digest is created with one line for each node-repository pair that has a copy of it.

Then, `REGISTRY` is queried and all its manifests are obtained, processed and re-uploaded. The processing of the JSON data structure each manifest is made of is delegated to a [Python script](../cooperative%20migration/update_manifest_urls.py) that searches for the corresponding file previously created in `WORK_DIR` and builds an array with its lines.
This array is then stored in the `urls` field of the manifest, described in the [specification](https://docs.docker.com/registry/spec/manifest-v2-2/#image-manifest-field-descriptions).

A [second script](../cooperative%20migration/cpull_migr_dest.sh), the one performing the actual container migration, has to be executed at the destination.
As previously stated, the process is basically the same as the one of the _Custom client scenario_, so we mention just the differences with respect to that:
- An additional command line argument in fourth position represents the location of the centralized Registry
- This is queried to obtain the manifest for the image (repository+tag) of the migrating container
- The manifest's JSON is parsed to select one URL for each layer not already locally present, to be used for retrieving the layer itself

The rest of the script is substantially unchanged.

For now, the first URL found is returned, but in general the selection can be based on a policy that takes into consideration parameters like the available bandwidth and nodes' workload.

### Push-based approach ###
ClusterKB listens to periodic updates sent by each node and to notification events emitted when there is a change in a node's Registry.

Because events - the information content of which is just an incremental difference - can be lost if there is no-one ready to listen to them (for example because of a full queue at the receiver side), periodic updates are sent with the entire information to compensate the loss of any previous events.
Ideally, with no event loss and timely delivery, the cluster-level knowledge base is always updated with fresh data.

#### Script ####
Nothing changes for the destination, but ...

## Destination-side Pull ##
If we get rid of ClusterKB, the destination itself may pull the list of layers its neighbors have. This can be done either **on-line**, when the migration request is issued, or **off-line**, by periodically querying them.

### Pull: on-line queries ###
When having to migrate a certain container image, the destination takes action and queries all its neighbors for nodes that have a copy of the image layers.

This requires a great overhead, but on the other hand its implementation is very straight forward and does not need to rely on any particular data structure. Additionally, fresh data is retrieved as a consequence of by-need pull requests.

#### Script ####
After the migration request is issued and the image manifest of the migrating container is obtained by the destination from the source, the former sends a series of GET requests to all its neighboring nodes for each missing layer.
To keep things easy, whenever a layer is found in a node's Registry, the layer's content is downloaded from that node without interrogating any other node, thus also reducing the migration overhead and avoiding the need to keep location URLs in memory at all.

```
URL=""
for NODE in ${NODES[@]}; do
  for REPO in $(get_repos $NODE); do
    echo "pull: querying $NODE $REPO ..."
    if test_layer.sh $NODE $REPO $DIGEST; then
      URL="$NODE/v2/$REPO/blobs"
      break
    fi
  done

  if [ $URL ]; then   # one URL found
    break             # exit from outer for cycle
  fi
done
```

A part for this, the rest of [the script](../cooperative%20migration/pullonln_migr_dest.sh) behaves as in previous examples.

### Pull: periodic requests ###
Compared to the previous scenario, in this case there is no overhead related to the single migration itself, as the data about layers location is already locally available from the last cycle of requests (_off-line_).

#### Script ####
One script takes care of periodic pull cycles and another one of the actual migration process. They are substantially the same as the ones of the [Centralized pull-based approach](#pull-based-approach), this time both to be executed at the destination.

> Because when pushing a manifest to a Registry all its layers have to be already present in the Registry itself, to actually use the mentioned scripts as they are you would need the destination to have all the layers in advance, making the migration to fall back to a trivial scenario (as there would be no new layers to be fetched).

> This limit can be overcome by introducing a dedicated data structure that keeps track of layers' locations: _the temporary files created by the master's script_ would make the cut, for example (see code below).

```
LAYER_FILE="$WORK_DIR/${DIGEST}.txt"
if [ -f "$LAYER_FILE" ]; then
	URL=$(head "$LAYER_FILE" -n 1)  # policy: first URL
else
	URL="$SOURCE_REGISTRY/v2/$IMAGE_REPO/blobs"
fi
```

## Off-line Push ##
The alternative for the destination is to listen to events emitted by its neighbors, so to have a local knowledge of their layers always updated. Similarly to the [Centralized push-based approach](#push-based-approach), periodic updates are also sent even when there are no changes to the node's Registry.

No overhead (off-line) and fresh data, but it may require an event broker to handle all notifications.
