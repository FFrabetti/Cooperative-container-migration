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
The script, to be executed at the source, can be found here: [bash file](standard%20migration/simple/ssl_migr_source.sh)

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
The script, to be executed at the source, can be found here: [bash file](standard%20migration/layered/lrm_migr_source.sh)

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
Compared to the case of a source-side Registry, the `pull` operation is replaced by a series of HTTP `GET` requests targeting the _individual layers_ not already present at the destination.

The granularity is no more just the container image, but its single constituent layers. This gives us more control over the pulling process, but we also have to re-implement the mechanism that checks whether a given layer is already locally present or not.
