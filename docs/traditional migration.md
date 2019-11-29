# Traditional migration #
With traditional migration we mean the case of a containerized service being migrated without the involvement of any other node besides the source and the destination. This is opposed to _cooperative migration_, where other neighboring (w.r.t. the destination) nodes contribute to the process.

#### Assumptions ####
- **Intra-cluster migration**: single cluster with centralized management (master-slave architecture)
- **Stateless migration**: stateless service (no session/per-user state) and no request state migration
- **Focus on the process itself**: fine coordination among nodes and control-plane implementation are kept for a later stage
  - Docker’s ecosystem as reference technology

##### Topology #####
The following examples assume that all the nodes of the cluster
- Know each other's IP address
- Have shared public keys and trust them
- Can use the same local username for `ssh` and `scp` operations
  - If needed, this can be configured through the variable `USER`

#### Scenarios ####
- [“Simple” migration: backup and restore](#simple-migration-backup-and-restore)
- Layered Registry-based migration
  - [Master-managed Registry](#master-managed-registry)
  - Peer-to-peer
    - [Destination-side Registry](#destination-side-registry)
    - [Source-side Registry](#source-side-registry)
  - [Custom client (single layers fetching)](#custom-client-single-layers-fetching)

## “Simple” migration: backup and restore ##
The _entire_ container image is transferred from the source to the destination.

#### Steps ####
1. Migration request issued to both nodes
2. Backup of the container at the source (**backup**)

   ```
   docker save -o $FILE_NAME $IMAGE
   ```
3. Backup sent to the destination
4. Backup extraction and new container started at the destination (**restore**)
   
   ```
   docker load -i $FILE_NAME
   docker run -d $IMAGE		# -p ...
   ```
5. User-service handover from source to destination
   - \(Original container stopped at the source)
   - Migration request status updated to `completed`

#### Script ####
The script, to be executed at the source, can be found here: [bash file](../standard%20migration/simple/ssl_migr_source.sh)

It requires 2 or 3 arguments, the first of which (`TO_HOST`) is the IP of the destination node. The others can be:
- `CONTAINER`: the migrating container name or ID
- `REPOSITORY TAG`: the container image, with a space instead of the common `:` separator

The backup file is stored locally at the source in the current directory, with the name `REPOSITORY.TAG.tar` (`/` replaced with `.`), then it is transferred to the destination over `scp` to `/tmp`.

Optional operations are preceded by a comment line in brackets and they may be commented out.


## Layered Registry-based migration ##
Image layers _not already present_ are transferred from the source to the destination.  
Layers are stored and distributed through the Docker Registry.

### Master-managed Registry ###
Layers are stored and distributed through the **master's Registry**.

#### Steps ####
1. Migration request issued to both nodes
2. The source uploads the container image layers (**push**)
   
   ```
   docker tag $IMAGE $REGISTRY_TAG
   docker push $REGISTRY_TAG
   ```
3. The destination downloads the layers it needs (**pull**)
   - Those already present locally are ***not downloaded***
   <br/>
   
   ```
   docker pull $REGISTRY_TAG
   docker run -d $REGISTRY_TAG		# -p ...
   ```
4. New container started at the destination
5. User-service handover from source to destination
   - \(Original container stopped at the source)
   - Migration request status updated to `completed`

#### Script ####
The script, to be executed at the source, can be found here: [bash file](../standard%20migration/layered/lrm_migr_source.sh)

Compared to the script of the [previous section](#script), this one requires an additional argument in second position: the name to be used to tag the container image so it can be pushed and pulled from the Registry.
It would normally be in the form: `REGISTRY[:PORT]/REPOSITORY:TAG`

### Destination-side Registry ###
Layers are stored and distributed through the **destination's Registry**.

#### Differences ####
The differences from the steps described for the case of a master-managed Registry are the following:

2. The `push` operation uploads just the layers _not already present at the destination_
3. The `pull` operation is entirely _local_ to the destination

The same script can be used with these variations:
- The Registry must be running at the destination (with notion of all the images used by its containers)
- The second argument must correctly address the destination's Registry

### Source-side Registry ###
Layers are stored and distributed through the **source's Registry**.

#### Differences ####
The differences from the steps described for the case of a master-managed Registry are the following:

2. The `push` operation can be skipped, as we assume that it has been done off-line (when the migration request is issued, the Registry already manages all the images present at the source)
3. The `pull` operation downloads just the layers _not already present at the destination_

The same script can be used with these variations:
- The Registry must be running at the source (with notion of all the images used by its containers)
- The second argument must correctly address the source's Registry

### Custom client (single layers fetching) ###
Layers are stored and distributed through the **source's Registry**.

#### Differences ####
Compared to the case of a source-side Registry, the `pull` operation is replaced by a series of HTTP `GET` requests to the source's Registry targeting the _individual layers_ required to run the container and not already present at the destination.

The granularity is no more just the container image, but its single constituent layers. This gives us more control over the pulling process, but we also have to re-implement the mechanism that checks whether a given layer is already locally present or not.

#### Steps ####
1. Migration request issued to both nodes
2. \[***off-line push***] _(A Registry at the source manages the images of all containers running on the node)_
3. The destination downloads from the Registry just the layers it needs (**GET**)
   1. Fetch the list of layers the image is made of
   2. For each layer, check its presence at the destination
   3. `GET` all new layers from the Registry
   4. Create container image at the destination
4. New container started at the destination
5. User-service handover from source to destination
   - \(Original container stopped at the source)
   - Migration request status updated to `completed`


#### Script ####
The script, to be executed at the destination, can be found here: [bash file](../standard%20migration/layered/lcc_migr_dest.sh)

To handle incoming images, a second Registry must be running at the destination. This allows to verify, given a layer's digest, if it is already present in one of the local repositories (step 3.2), and to correctly manage the acquired layers and image meta-data (in the form of a _manifest_) at the destination (step 3.4).

The script accepts 4 parameters: the source's address, the migrating container image repository and tag and, optionally, the destination's Registry address (default: `localhost:5000`)

The sub-steps of 3. described above are implemented as follows:
1. Get the image manifest
   ```
   curl $SRC_REGISTRY/v2/$REPOSITORY/manifests/$TAG -o "$MANIFEST_FILE" \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json"
   ```
   from which you can obtain the list of layers and their digests (field `layers` \[array] and `layers[X].digest`).
   
2. Check the presence of a given layer (through its digest) in a (local) repository
   ```
   curl $REGISTRY/v2/$REPOSITORY/blobs/$DIGEST \
		-I -X HEAD \
		-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip"
   ```
   Positive with a `200 OK` response.
   
   If the layer exists in `REPOSITORY`, then it can be mounted to the target repository
   ```
   curl "$REGISTRY/v2/$TARGET_REPO/blobs/uploads/?mount=$DIGEST&from=$REPOSITORY" \
		-I -X POST \
		-H "Content-Length: 0"
   ```

3. Otherwise, the layer must be fetched from the source's Registry
   ```
   curl "$SRC_REGISTRY/v2/$REPOSITORY/blobs/$DIGEST" -o "$LAYER_FILE" \
		-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip"
   ```

4. Each new layer must be pushed to the local Registry by first getting an upload URL (`UPLOAD_URL`)
   ```
   curl $REGISTRY/v2/$REPOSITORY/blobs/uploads/ \
		-I -X POST \
		-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip"
   ```
   If `202 Accepted` response, the upload URL is returned in the `Location` header.
   
   Then, given `LEN` the size in bytes of the layer, this can be uploaded as a single chunk (_monolithic upload_). See the [documentation](https://docs.docker.com/registry/spec/api/#uploading-the-layer) for additional details and options.
   ```   
   curl -v "$UPLOAD_URL?digest=$DIGEST" \
		-X PUT \
		-H "Content-Length: $LEN" \
		-H "Range: 0-$LEN" \
		-H "Content-Type: application/octet-stream" \
		--data-binary @"$LAYER_FILE"	
   ```

   The destination's Registry also needs the _configuration blob_, with data like the version/tag of the image, it's reference architecture and OS, and so on.
   This must be downloaded from the source and uploaded in a similar fashion to what has been done for the image layers:
   ```
   curl $SRC_REGISTRY/v2/$REPOSITORY/blobs/$CONF_DIGEST -o "$CONF_FILE" \
		-H "Accept: application/vnd.docker.container.image.v1+json"
   ```
   its digest and length (`CONF_DIGEST` and `CONF_LEN`) can be obtained from the image manifest (`config.digest` and `config.size`).
   ```
   curl $REGISTRY/v2/$REPOSITORY/blobs/uploads/ \
		-I -X POST \
		-H "Accept: application/vnd.docker.container.image.v1+json"
   ```
   If `202 Accepted` response, the upload URL is returned in the `Location` header.
   ```
   curl "$UPLOAD_URL?digest=$CONF_DIGEST" \
		-X PUT \
		-H "Content-Length: $CONF_LEN" \
		-H "Range: 0-$CONF_LEN" \
		-H "Content-Type: application/octet-stream" \
		--data @"$CONF_FILE"
   ```
   
   Finally, the manifest itself can be uploaded to the local Registry
   ```
   curl "$REGISTRY/v2/$REPOSITORY/manifests/$TAG" \
		-X PUT \
		-H "Content-Type: application/vnd.docker.distribution.manifest.v2+json" \
		--data @"$MANIFEST_FILE"
   ```
