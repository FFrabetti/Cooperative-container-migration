# Orchestrating migrations #
The main objective of container migration is improving some QoS indicators which are currently worse than their tolerated value.
This requires that:
- **QoS indicators** of interest are constantly **monitored**
- A **migration policy** is used to decide _when_, _who_ and _where to_ migrate (based on the indicators from above)

Additionally, the problem of migration involves other things as well, besides the monitoring of certain parameters across the network, like nodes synchronization, the ability to react to failures and unexpected behaviors, seamless traffic redirection, and so on. What we need, in other words, is an orchestration layer.

Although this is beyond the scope of this project, as it is the migration process that is relevant for our work, we briefly detail here how a single migration can be carried out through an orchestrator in a wider perspective.

***For the sake of our experiments, however, we are statically deciding ahead of time which migrations have to be carried out, without the need of a proper orchestration engine.***

## Migration control cycle ##
We have already given an idea of how the system (a cluster) should work in a "normal", steady, state: for each service/container running on any node, a number of QoS indicators have to be monitored with a certain frequency and fed to a given migration policy. To keep things simple, we can assume that all services have the same requirements in terms of QoS, so the same values and policies can be applied to any container in the system.

This "ideal" state is just a static representation of a moment in time when no migrations are happening, but whenever the policy decides that a migration is required, a series of things have to take place:
- A migration request is issued to the source and the destination, targeting a specific container running at the former
- The destination updates the migration status (starting from `Issued`) throughout the process:
  - `InProgress` when the request is received and the procedure has started
  - `Complete` once the migration is successfully completed (a new container is running at the destination and the old one at the source is stopped)
  - `Failure` if an error prevented the migration from happening (a failover plan may take place at this point)
- In case of termination with success, the traffic of the migrating container has to be redirected transparently to the user

> The type of migration we are referring to here is **reactive**, in the sense that the system is acting in response to a change in the operating conditions of the service (as opposed to a proactive migration, which starts _before_ things actually change), and **centrally managed**, i.e. it is not the user/client or the service deciding to migrate, but the decision comes from another entity which knows the current status of the system and is in charge of the whole process.

The idea of having a central controller (or more than one) dedicated to management purposes is at the foundation of many orchestrators following a **master-slave architecture**, like [Kubernetes](https://kubernetes.io/) and [Docker Swarm](https://docs.docker.com/engine/swarm/).

> Let's note that no control/orchestration plane has been implemented in our system, but the following sections give an idea of how things _could_ be implemented in real-world scenarios from a high-level point of view.

### Monitoring ###
Monitoring the status of the system is usually a main component of the orchestration layer activity, which is interested in the resources available at each node (and its health condition) and in the ones currently utilized by the tasks running on that node.
This can be the job of a [node controller](https://kubernetes.io/docs/concepts/architecture/nodes/#node-controller) or of some other entity (like a [metrics-server](https://kubernetes.io/docs/tasks/debug-application-cluster/resource-usage-monitoring/)) concerned about different sets of metrics.
Those pieces of information can then be used for [automatically scaling tasks](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-metrics-apis) or, more relevant to our topic, as input data for a migration policy.

Custom metrics can normally be configured if the ones already provided are not sufficient ([Custom Metrics API implementations for Kubernetes](https://github.com/kubernetes/metrics/blob/master/IMPLEMENTATIONS.md#custom-metrics-api)). Another way of keeping track of what is happening in the system is by the use of [logs](https://kubernetes.io/docs/concepts/cluster-administration/logging/). 

### Reactive mechanism through controllers ###
Metrics data somehow collected with one of the alternatives presented above has to be constantly fed to the migration policy so it can decide if a migration is needed. In that case, to close the loop, someone has to act accordingly.

This behavior is the one of a [Controller](https://kubernetes.io/docs/concepts/architecture/controller/):
> A controller tracks at least one Kubernetes resource type. These objects have a spec field that represents the desired state. The controller(s) for that resource are responsible for making the current state come closer to that desired state.

In our scenario, a _migration controller_ should issue the migration request and act upon the state of the system (e.g. the API server) to make sure that all the steps of service migration are being carried out by the entities involved.

### Custom resources and controllers ###
The migration request and the migration itself are examples of custom entities the orchestration layer may not natively have. For this reason, one may need to define its own resources in addition to the controllers related to them envisioned in the previous section.

In Kubernetes, there are two ways of extending the provided API: with _Custom Resource Definitions_ or with _API server aggregation_.
- [Custom Resources](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)
- [Extend the Kubernetes API with CustomResourceDefinitions](https://kubernetes.io/docs/tasks/access-kubernetes-api/custom-resources/custom-resource-definitions/)
- [Extending the Kubernetes API with the aggregation layer](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/apiserver-aggregation/)
- [Configure the Aggregation Layer](https://kubernetes.io/docs/tasks/access-kubernetes-api/configure-aggregation-layer/)
- [Setup an Extension API Server](https://kubernetes.io/docs/tasks/access-kubernetes-api/setup-extension-api-server/)

### Transparent service migration ###
The orchestration layer usually provides some abstractions that allow a service to be independent from the node/task serving the requests and its location. This may be done through the use of virtual IPs, DNS names and FQDN associated with each [service](https://kubernetes.io/docs/concepts/services-networking/service/).

A similar approach would be to use global names associated with services to be resolved via a global name resolution service (GNRS): a gateway router would then be able to route traffic to the location returned by the GNRS, which is independent from the name used to identify the service.

#### Final remarks ####
Similar concepts to the ones presented here for Kubernetes, as an example, can be found in Docker Swarm as well; their underlying principles may apply, in fact, to any orchestrator that follows a master-slave architecture and control-loop mechanisms based on declarative resources/API.
