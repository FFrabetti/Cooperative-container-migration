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

### SourceProxy ###

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

### Layers metadata off-line exchange ###
`DestinationProxy` has to transmit to its peer which layers can be found in its cluster. The cluster-level Registry would already have all the data about that, organized in the image manifests.

`SourceProxy` has to receive this information and publish it to its cluster's Registry under its own address, optionally together with the "total cost" to retrieve each layer.

An implementation of such mechanisms is already available in [cpull_migr_master.sh](../cooperative%20migration/cpull_migr_master.sh) (used for the [centralized pull scenario](cooperative%20migration.md#pull-based-approach)), to be executed as follows:
```
cpull_migr_master.sh DEST_CLSTR_REGISTRY PERIOD WORK_DIR SRC_CLSTR_REGISTRY
```

## Example ##

### Setup ###
The same setup script presented [here](cooperative%20migration.md#example) can be used to configure the Registry (the one at the source cluster) with the appropriate `urls` fields.

At `DestinationProxy`
```
mkdir cache_dir
dest_proxy.py 8080 cache_dir https://REGISTRY
```

At `SourceProxy`
```
mkdir cache_dir
source_proxy.py 8080 cache_dir DEST_PROXY:8080
```

### Fetch a layer ###
To test if a container image layer can be fetched through the two proxies, you can try:
```
curl "SOURCE_PROXY:8080/v2/REPO/blobs/DIGEST"
```

### Topology ###
Clusters can be identified by dedicated [overlay networks](https://docs.docker.com/network/overlay/). Similarly, an additional overlay network comprising the two proxies may allow inter-cluster communications (its traffic may be encrypted at the price of additional overhead).
