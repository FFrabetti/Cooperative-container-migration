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
Nothing changes for the destination, but we have to set things up on all nodes so they start sending notifications and periodic updates to the master. We tackle these two problems separately.

##### Sending notifications #####
The Registry has its own internal [notification system](https://docs.docker.com/registry/notifications/), which sends _events_ (in the form of JSON objects in the payload of HTTP requests) to a set of pre-defined endpoints specified in the configuration yaml file. Each event refers to an operation (_request_) performed on the Registry to a specific _target_ resource, mainly a layer or a manifest.

With [minimal configuration](../various/config/config_notify_1_8000.yml) we set each node's Registry to send notifications to an endpoint (`ENDPOINT:PORT`) running on the master:
```
notifications:
  events:
    includereferenes: true
  endpoints:
  - name: pylistener
    url: ENDPOINT:PORT
    headers:
    timeout: 1s
    threshold: 5
    backoff: 5s
    ignore:
      actions:
      - pull
```
Note that we ignore _pull_ actions, as they do not change the status of the Registry.

On the master side, a HTTP endpoint has to be running at the specified port, parse the received events and update the master's own Registry accordingly. We implemented the [HTTP server](../cooperative%20migration/notifications_endpoint.py) and the JSON parsing (both for events and [image manifests](../cooperative%20migration/update_manifest.py)) in Python, while a simple [bash script](../cooperative%20migration/update_registry.sh) takes care of updating the Registry.

To be executed at the master:
```
python3 notifications_endpoint.py PORT | update_registry.sh MASTER_REGISTRY
```

##### Sending periodic updates #####
The simplest way of sending periodic updates is by turning them into the same event format used by the Registry, so we can re-use the same endpoint and update logic.

This is done in [this script](../cooperative%20migration/periodic_push.sh), which accepts as parameters the local Registry to get the information from, the update period, in seconds, and a list of endpoints to notify.
For each manifest and for each layer in it, a "fake" _push_ event is generated and sent to all endpoints with the layer's digest, repository and full URL.

> Please note that a smarter, distributed version of the script could also transmit the information about other nodes it has notion of, by attaching the content of the `urls` field present for each layer in the local Registry. Additionally, one could think of propagating the information to the endpoints obtained from the `urls` array itself.

An obvious problem with this solution is about the fact that, by design, these "fake" events would always come in batches, while the endpoint, as it is, works for single events, i.e. it performs a full scan of the local Registry and updates it _for every event_.
An optimized version, on the other hand, could examine a batch of events and, for each batch:
1. Scan the locally present manifests
2. For each layer, if present in the batch, update its `urls` array
3. Push the updated manifest back to the Registry

This is done by these [Python](../cooperative%20migration/endpoint_rev_table.py) and [bash](../cooperative%20migration/update_registry_rev_table.sh) scripts.
```
endpoint_rev_table.py PORT | update_registry_rev_table.sh MASTER_REGISTRY
```

A dedicated HTTP server is ready to receive a summary of the content of a node's Registry (again in JSON format), with one entry for each layer containing its digest and a list of URLs (comprising the layer's location in the Registry and the content of the `urls` field).
```
{ "layers": [
	{
		"digest": "...",
		"urls": [ "...", ... ]
	},
	...
] }
```

Finally, a [script](../cooperative%20migration/periodic_push_rev_table.sh) (similar to the one of the simpler version and with the same parameters) running on each node has to periodically send the `layers` JSON structure, which, if compared to how the same information is stored in the Registry, can be seen as a sort of **inverse table**: given a layer's digest, tell me where to find it (URL with node/Registry IP, repository, etc.).

> A Registry normally works the other way around, as it is interrogated knowing the repository and the resource digest (besides the Registry location). This is why a common pattern in many of the scripts presented in this section is a full scan of the repositories, manifests and layers managed by a Registry.

Note that the script, for simplicity reasons, does not "compact" the list to avoid duplicates, so there may as well be multiple entries for a single layer. Replicated values, however, are been taken care of at the receiver side.

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

> Because when pushing a manifest to a Registry all its layers have to already be present in the Registry itself, to actually use the mentioned scripts as they are you would need the destination to have all the layers in advance, making the migration to fall back to a trivial scenario (as there would be no new layers to be fetched).

> This limit can be overcome by introducing a dedicated data structure that keeps track of layers' locations, to be used instead of the Registry: _the temporary files created by the master's script_ would make the cut, for example. The code snippets below show how this data structure can be accessed in read (when looking for a layer) and write mode:

```
LAYER_FILE="$WORK_DIR/${DIGEST}.txt"
if [ -f "$LAYER_FILE" ]; then
	URL=$(head "$LAYER_FILE" -n 1)  # policy: first URL
else
	URL="$SOURCE_REGISTRY/v2/$IMAGE_REPO/blobs"
fi
```
(from [this script](../cooperative%20migration/cpull_migr_dest.sh), as the destination may obtain the layer URL from its local filesystem instead of from the master's Registry)

```
LAYER_FILE="$WORK_DIR/${DIGEST}.txt"
LINE="$REGISTRY/v2/$IMAGE_REPO/blobs"

if [ ! -f "$LAYER_FILE" ] || ! grep -q "^${LINE}$" "$LAYER_FILE"; then
	echo "$LINE" >> "$LAYER_FILE"
fi
```
(from [this script](../cooperative%20migration/cpull_migr_master.sh), with minor changes)

## Off-line Push ##
To avoid the overhead of performing an on-line scan of its neighbors while not giving up on the benefit of having fresh data, the alternative for the destination is to listen to events emitted by neighboring nodes, so to have a local knowledge of their layers always updated. Similarly to the [Centralized push-based approach](#push-based-approach), periodic updates are also sent even when there are no changes to the node's Registry.

This approach suffers the same problem described above about the Registry having to manage all layers in advance; additionally, the fact that notification endpoints must be statically defined in the configuration file prior to the Registry execution makes nodes set up complicated and the entire system unable to cope with changes in the network topology.

A common design pattern for such scenarios is introducing a third entity to de-couple the emission of notification messages from their potential targets. This is done with the help of an **event broker** that follows a publish/subscribe delivery method: each node publishes notifications to a specific topic in a known endpoint, the broker, which in turns notifies all the previously subscribed nodes.

The broker may have a separate topic for each neighborhood or even a dedicated one for every node: an edge node can then subscribe to one or multiple "neighborhoods" or to the topics of all its neighbors. The former case requires to publish, in general, the same event to multiple topics (as a node can belong to many neighborhoods), while the latter has the downside of requiring subscribers to know the logical name associated with the topic of all their neighbors.

#### Script ####
We detail here how the [Centralized push-based approach](#push-based-approach) example can be extended to include an event broker. To keep things simple, we consider that:
- periodic updates are sent in the form of JSON events, the same used for Registry notifications
- the Registry in execution on a subscriber node can deal with information about layers it does not already manage

For the broker is chosen [_Eclipse Mosquitto_](https://mosquitto.org/), an open-source MQTT message broker. It must be running on a (master) node within the cluster:
```
docker run -d -p 1883:1883 -p 9001:9001 eclipse-mosquitto
```

on each node, its default clients must be installed (for Ubuntu):
```
sudo apt-get install mosquitto-clients
```

A subscriber must be running on every node, with the task of interfacing with the script that updates the local Registry:
```
mosquitto_sub -h BROKER -t TOPIC | update_registry.sh REGISTRY
```

While an HTTP endpoint (whose IP and `PORT` are set in the Registry configuration file) and a publisher must be executed on the master:
```
# publish to localhost one message per line (stdin), with debug output
python3 notifications_endpoint.py PORT | mosquitto_pub -d -l -t TOPIC
```

Thanks to the de-coupling present in the architecture of the original example between the HTTP server (in Python) and the script that implements the Registry update logic (in bash), nothing else needs to be changed.

> At default, the least QoS level (0) is used, which means that messages are delivered without acks or retransmissions, in favor of lower latency. An optional _retention_ flag can be set for periodic updates to prevent messages already delivered to all subscribers from being immediately discarded: in this way, in case of a new subscription, the broker can send the "last known good" value without having to wait for the next update cycle.

## Example ##
At the end of the day, we are interested in what happens during a migration, while control messages and Registry updates can be considered as a separate problem by themselves.
Therefore, we go back to the same example proposed [here](traditional%20migration.md#example) but for cooperative migration.

> The scripts introduced below refer to the centralized scenario where a Registry with all the images of the cluster is running at the master, but if we move the Registry to either the source or, in case, the destination, everything works as fine.

A [script](../cooperative%20migration/cm_example_source.sh) to be executed at the source allows us to easily build, tag and push the container image to the Registries present at the source and at the master (previously started).

```
cm_example_source.sh $SOURCE $REPO $VERS $MASTER
```
We are again using the same two-layer-image introduced in the other example, with the master Registry configured as follows:
- top-most layer: available just through the source
- bottom layer: available both at the source and at the master

At the destination:

```
tmp_registry.sh 	# start an insecure Registry at localhost:5000
cpull_image_dest.sh https://$SOURCE $REPO:$VERS https://$MASTER localhost:5000

docker run --rm localhost:5000/$REPO:$VERS /bin/sh -c 'cat layerfile | tail'

tmp_registry.sh stop
docker image rm localhost:5000/$REPO:$VERS
```

> [cpull_image_dest.sh](../cooperative%20migration/cpull_image_dest.sh) would try to fetch missing layers from the first URL obtained from the manifest returned by the master, using the master itself as a source if the `"urls"` field is empty.
> This is the reason why in the [traditional migration example](traditional%20migration.md#example) the third argument was again `https://$SOURCE`.

> Note that by using the same arguments of the traditional case, but with a properly configured Registry at the source (for example), you can fetch layers from multiple nodes without requiring a third (master) node.
