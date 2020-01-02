# TrafficGen #
The test application has to generate network traffic according to the [4 categories defined by 3GPP](#TODO):
- [interactive](#interactive) (request/response)
- [conversational](#conversational) (e.g. event-based)
- [background](#background) (unidirectional bursts)
- [streaming](#streaming)

Additionally, it has to:
- read/write session state
- read/write storage data
- experience some processing latency

Client and server applications also have to produce sufficient logs to allow latency measurements over the 4 scenarios described above.

Both applications are written in Java, using Java EE servlets and web sockets. Tomcat is used as application server.

## Configuration ##
The main configuration files are:
- **pom.xml** for Maven
  - [trafficgen/pom.xml](../java/trafficgen/pom.xml)
  - [trafficgencl/pom.xml](../java/trafficgencl/pom.xml)
- **web.xml** for server-side configuration
  - [trafficgen/src/main/webapp/WEB-INF/web.xml](../java/trafficgen/src/main/webapp/WEB-INF/web.xml)
- **log4j2.xml** for Log4j logging
  - [trafficgen/src/main/resources/log4j2.xml](../java/trafficgen/src/main/resources/log4j2.xml)
  - [trafficgencl/src/main/resources/log4j2.xml](../java/trafficgencl/src/main/resources/log4j2.xml)

For example, from _web.xml_ it is possible to set the directory used by the server to read/write to disk, while in _log4j2.xml_ one can configure where log messages are sent to (console, files, ...) and in what format.

> The log level INFO is chosen for records to be collected for measurement purposes, DEBUG for additional information about the program execution, while WARN and ERROR are for problems and exceptions.

## Build from source ##
Building and packaging are automated with Maven: the `package` goal produces `.war` (server) and `.jar` (client) archive files in the `<PROJECT>/target` directory.

Required libraries are copied into `<PROJECT>/dependency-jars` (included in the classpath).

> Note that libraries already provided by Tomcat and required at compile time should **not** be included when distributing the server application.

## Deployment as Docker images ##
In two separate directories copy the archive files (`war` or `jar`) together with `dependency-jars`.

Then create a `Dockerfile` with this content for `trafficgen`:
```
FROM tomcat:8.0-alpine
COPY . /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]
```

and the following for `trafficgencl`:
```
FROM java:8
COPY . ./
```

In each directory run:
```
docker build -t IMAGE:TAG .
```
where `IMAGE` should be something like `trafficgen` or `trafficgencl` respectively, and `TAG` an increasing version number.

> The newly created container images may also be pushed to a Registry.

## Usage ##
Here are reported some examples of usage of the two applications.

```
docker run -d -p 8080:8080 -v myvol:/usr/local/tomcat/myvol \
	--name trafficgen trafficgen:1.0
```

> Logs can be found within the container in `/usr/local/tomcat/logs` (with the current configuration) or, for the ones sent to the console, by executing `docker logs trafficgen`.

```
docker run -it -v /logs:/logs \
	--name trafficgencl trafficgencl:1.0 \
	java -jar trafficgen.jar interactive http://<SRV_ADDR>:8080/trafficgen/interactive
```

```
docker run -it -v /logs:/logs \
	--name trafficgencl trafficgencl:1.0 \
	java -jar trafficgen.jar conversational ws://<SRV_ADDR>:8080/trafficgen/conversational/5000
```

## Interactive ##
Interactive traffic can easily be realized on top of HTTP request/response mechanism.

Its implementation requires the client to take the initiative and send a HTTP request (GET) to a server resource with URL `/[s]interactive`, where the optional `s` stands for _stateful_.
With each request, a series of parameters are included: the time (in milliseconds) the server has to wait before sending the response, its payload size and, just for the stateful endpoint, the size of session and storage/disk state.

These pieces of information are read by the client application from the standard input, in the form:
```
MIN_PR_TIME RES_SIZE [SES_SIZE] [DISK_SIZE]
```

The client logs a message before sending the request (1) and right after receiving the response (4).
Similarly, the server logs when the request is received (2) and before the response is issued (3).

With the assumption of clock synchronization:
- (2)-(1) represents the uplink latency
- (4)-(3) represents the downlink latency
- (3)-(2) is the processing latency
- (4)-(1) is the total end-to-end latency

> `SES_SIZE` and `DISK_SIZE` do not exactly match the amount of bytes read/written in memory and disk respectively, but they are a close approximation of a proportional relationship, i.e. `SES_SIZE`=20 would roughly involve twice the amount of session state compared to `SES_SIZE`=10.

## Conversational ##
For this and the following types of traffic, a WebSocket is used as a bidirectional channel between client and server: whenever one of the two has something to send, it writes it in the WebSocket.

Despite exchanged messages can be of various types, to keep things simple we only implement string-based messages. Binary messages of variable size are used in the following sections.

The client implementation is similar to the one used for interactive traffic: a message is sent for each line read from standard input.
The URL (e.g. `ws://<SRV_ADDR>/trafficgen/conversational/<MAX_PERIOD>`) has a positive parameter, `<MAX_PERIOD>`, used by the server to set the upper bound for uniformly distributed values that represent the period (in milliseconds) between two consecutive messages.

E2E latency can be measured by considering the timespan between a message being sent and its reception (need for clock synchronization).

> Messages are sent in synchronous mode, i.e. the sender is blocked until the entire message has been transmitted.

The server simply echoes the client last message with a counter added before it so each message is different. The session state is therefore comprised of the last received message and the current value of the counter (re-started whenever a new client message arrives).

## Background ##
For background traffic, the server sends partial binary "chunks" of data of configurable size and number. These can be changed at runtime by sending a message in the format:
```
N_CHUNKS CHUNK_SIZE
```

Everything else works as described for conversational traffic.

## Streaming ##
In this case, the server endpoint URL requires a parameter that indicates the number of bytes per second it has to send through the WebSocket.

Any message from the client stops the stream.

> When the sender thread running server-side is interrupted, the client input stream closes, causing the termination of the receiving thread client-side.
