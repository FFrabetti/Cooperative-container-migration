# Multi-cluster stateless migration #

With stateless migration, the only concerns are retrieving the image layers of the migrating container, starting a new container at the destination and then stopping the original one at the source.

When `SourceProxy` receives a request for a given layer (identified through its digest), it has to:
1. Check if a cached copy of it is already locally present: if this is the case, return it
2. If not, ask its counterpart and return whatever it receives back

`DestinationProxy`, when asked, has to:
1. Check if a cached copy of it is already locally present: if this is the case, return it
2. If not, check in the Registry where to get it from (at least the source has it), fetch it and forward it to `SourceProxy`

Copies of the content are always cached at all intermediate proxies. A policy for invalidating cached content is assumed to be in place.

## Implementation ##

The same REST API used by the Registry is used by the two proxies, with synchronous HTTP requests carrying the name of the repository and the digest of the layer to be fetched.

### SourceProxy ###
A simple HTTP server/client has been implemented in Python, with 3 required arguments (`port`, `cache_dir`, `peer_proxy`) and whose core business logic is reported here:

```
def respond(self):
	digest = self.path.split('/')[-1]

	cacheFile = cache_dir.joinpath(digest)
	if cacheFile.is_file():
		size = cacheFile.stat().st_size
		with cacheFile.open('rb') as f:
			self.handle_http(200, 'application/octet-stream', size, f)
	else:
		conn = HTTPConnection(peerProxy)
		conn.request("GET", self.path)
		resp = conn.getresponse()
		self.handle_http(resp.status, resp.getheader('Content-Type'), resp.getheader('Content-Length'), resp)
```
[source_proxy.py](../multi-cluster/source_proxy.py)

### DestinationProxy ###
Symmetrically, the other side requires as arguments: `port`, `cache_dir` and `registry`.

```
def respond(self):
	digest = self.path.split('/')[-1]

	cacheFile = cache_dir.joinpath(digest)
	if not cacheFile.is_file():
		subprocess.run(["dp_fetch_layer.sh", registry, str(cache_dir.absolute()), self.path])

	if cacheFile.is_file():
		size = cacheFile.stat().st_size
		with cacheFile.open('rb') as f:
			self.handle_http(200, 'application/octet-stream', size, f)
	else:
		body = bytes("Layer not found", "UTF-8")
		self.handle_http(404, 'text/html', len(body), body)
```
[dest_proxy.py](../multi-cluster/dest_proxy.py)

[dp_fetch_layer.sh](../multi-cluster/dp_fetch_layer.sh)

### Layers metadata off-line exchange ###
`DestinationProxy` has to transmit to its peer which layers can be found in its cluster. The cluster-level Registry (or its own local Registry, for the fully distributed scenario) would already have all the data about them, organized in the image manifests.
`SourceProxy` has to receive this information and publish it to its cluster's Registry under its own address, optionally together with the "total cost" to retrieve each layer.

An implementation of such mechanisms is already available in [cpull_migr_master.sh](../cooperative%20migration/cpull_migr_master.sh) (used for the [centralized pull scenario](cooperative%20migration.md#pull-based-approach)), to be executed as follows:
```
cpull_migr_master.sh DEST_CLSTR_REGISTRY PERIOD WORK_DIR SRC_CLSTR_REGISTRY
```

> The assumption is that the entity executing the script can reach both Registries. This implementation can, however, easily be adapted to include a proper exchange protocol between the two proxies, if needed.

> In our simple version, the cost of each layer is "hidden" in its order within the array of `urls` stored in the manifest, with the implied behavior that a policy would prefer the ones at the top of the list.

## Example ##

### Setup ###
The same setup script presented [here](cooperative%20migration.md#example) can be used to configure the Registry (the one at the source cluster) with the appropriate `urls` fields.

Then, run the `DestinationProxy` in the source cluster:
```
mkdir cache_dir
dest_proxy.py 8080 cache_dir https://REGISTRY
```

And `SourceProxy` at the destination cluster:
```
mkdir cache_dir
source_proxy.py 8080 cache_dir DEST_PROXY:8080
```

Assuming that `DEST_PROXY` is the address of the former. The `8080` port and a dedicated folder for cached content (`cache_dir`) are used in both cases, but they abviously don't have to be the same.

### Fetch a layer ###
To test if a container image layer can be fetched through the two proxies, you can try:
```
curl "SOURCE_PROXY:8080/v2/REPO/blobs/DIGEST"
```
