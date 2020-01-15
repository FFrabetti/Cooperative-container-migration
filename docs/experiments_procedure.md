# Experiments procedure #

- Set up the topology and nodes configuration
  - Clusters, neighboring nodes, etc.
  - For multi-cluster, gateway proxies and the tunnels between them
  - Registries pre-populated with cluster data
- Define a "migration plan" for all the migrations that are going to happen
  - _When_, _who_, _where to_ statically decided ahead of time 
- Start scripts for monitoring QoS indicators
  - Workload
  - Traffic
  - (End-to-end latency is measured by post-processing application logs)

Types of experiment:
- [Single cluster](#single-cluster)
  - Stateless
  - Stateful
- [Multi-cluster](#multi-cluster)
  - Stateless
  - Stateful

For each of the above, we have 3 schemes:
- **Centralized Traditional Container Migration** (CTCM)
- **Centralized Cooperative Container Migration** (CCCM)
- **Distributed Cooperative Container Migration** (DCCM)

## Single cluster ##
### Stateless ###
#### Stateless CTCM ####
#### Stateless CCCM ####
#### Stateless DCCM ####

### Stateful ###
#### Stateful CTCM ####
#### Stateful CCCM ####
#### Stateful DCCM ####


## Multi-cluster ##
### Stateless ###
#### Stateless CTCM ####
#### Stateless CCCM ####
#### Stateless DCCM ####

### Stateful ###
#### Stateful CTCM ####
#### Stateful CCCM ####
#### Stateful DCCM ####
