# Experiments procedure #

For all experiments we have to:

- Set up the topology and nodes configuration
  - Clusters, neighboring nodes, etc.
  - Nodes "baseline" workload, channels characteristics (latency, bw, error rate)
  - Registries pre-populated with cluster data
  - For multi-cluster, gateway proxies and the tunnels between them
- Start scripts for monitoring QoS indicators
  - Workload
  - Traffic
  - (End-to-end latency is measured by post-processing application logs)

#### Nodes configuration ####
Make sure that all scripts, i.e. all `.sh` and `.py` files, are in a directory included in the `PATH` (e.g. `~/bin`).

Check which nodes are actually up and running and with the right IP for `eth0`.

#### Types of application/traffic ####
TODO

### Types of experiment ###
- [Single cluster](#single-cluster)
  - Stateless
  - Stateful
- [Multi-cluster](#multi-cluster)
  - Stateless
  - Stateful

For each of the above, we have 3 schemes:
- **Traditional Container Migration** (TCM)
- **Centralized Cooperative Container Migration** (CCCM)
- **Distributed Cooperative Container Migration** (DCCM)

## Single cluster ##

For single cluster experiments we require at most 6 nodes:
- Source `S`
- Destination `D`
- Master `M`
- Client `C`
- Neighbor1 `N1`
- Neighbor2 `N2`

We call each channel with its endpoints. In particular, we are interested in the following:
- `SD`
- `CS`
- `CD`
- `DM`
- `DN1`
- `DN2`

We assume all channels to be bidirectional and perfectly symmetrical.

### Stateless ###

Because we are considering just 2 nodes neighboring the destination, we limit the number of layers for the migrating container to 4, _one_ of which we assume is _already present at the destination_ and _one_ that _only the source has_. Their size is an input parameter.

> Actually, just the sizes of the top 3 layers are relevant, as the one(s) already at the destination does not affect the migration process. To keep things simple, their size is the same.

As read-only volumes do not differ much, from the migration point of view, from an image layer, we are not adding any of them in the case of stateless migration.

#### Stateless TCM ####

We need just these nodes: `S`, `D` and `C`, with a Registry running at the source and at the destination.
We consider all the channels between the three of them (`SD`, `CS`, `CD`).

> In a "centralized" version, the image manifest and, optionally, the container layers content itself would be fetched from a Registry located at the master, but this case would be extremely similar to the proposed one and of little interest.

Network scenarios (latency, bandwidth, error rate):

Ntw X   | `SD` | `CS` | `CD`
------- | ---- | ---- | ----
Ntw 1   |      |      |
Ntw 2   |      |      |
Ntw 3   |      |      |

Baseline workload:

Wl X | `S` | `D`
---- | --- | ---
Wl 1 |     |
Wl 2 |     |
Wl 3 |     |

Layers size:
- Small:
- Medium:
- Big:

Layers distribution (* identifies where the layer is fetched from):

Layer | `S` | `D`
----- | --- | ---
La    | Y   | Y*
Lb    | Y*  | N
Lc    | Y*  | N
Ld    | Y*  | N

#### Stateless CCCM ####

Additionally to what we have defined for TCM, in this case we also need `M`, `N1`, `N2`, and all nodes have their own local Registry. All channels are required.

Network scenarios:

Ntw X   | `DM` | `DN1` | `DN2`
------- | ---- | ----- | -----
Ntw 1   |      |       |
Ntw 2   |      |       |
Ntw 3   |      |       |

Baseline workload:

Wl X | `N1` | `N2`
---- | ---- | ----
Wl 1 |      |
Wl 2 |      |
Wl 3 |      |

Layers distribution (* identifies where the layer is fetched from):

Layer | `S` | `D` | `N1` | `N2`
----- | --- | --- | ---- | ----
La    | Y   | Y*  | Y    | N
Lb    | Y   | N   | Y*   | N
Lc    | Y   | N   | Y    | Y*
Ld    | Y*  | N   | N    | N

#### Stateless DCCM ####

Compared to the previous scenario, we don't have `M` nor `DM`. The destination would get the manifest from its own local Registry, while the layers content from the source and its neighbors.
This is the case of big clusters where each node would just advertise the content it has to its neighbors, without the need of a central entity (which may become a bottleneck or a single point of failure).


### Stateful ###

#### Stateful TCM ####

#### Stateful CCCM ####

#### Stateful DCCM ####


## Multi-cluster ##

### Stateless ###

#### Stateless TCM ####

#### Stateless CCCM ####

#### Stateless DCCM ####

### Stateful ###

#### Stateful TCM ####

#### Stateful CCCM ####

#### Stateful DCCM ####
