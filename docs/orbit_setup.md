# Container Migration Set-up on ORBIT #

The ORBIT open access testbed for next-generation wireless networking at Rutgers University, developed under the National Science Foundation’s NRT (Network Research Testbeds) program addresses the challenge of supporting realistic and reproducible wireless networking experiments at scale.  

The ORBIT large-scale radio grid emulator consists of an array of ~20x20 open-access programmable nodes each with multiple 802.11a,b,g or other (Bluetooth, Zigbee, GNU) radio cards. The radio nodes are connected to an array of backend servers over a switched Ethernet network, with separate physical interfaces for data, management and control.  Interference sources and spectrum monitoring equipment are also integrated into the radio grid.  Users of the grid emulator system log into an experiment management server which executes experiments involving network topologies and protocol software specified using an ns2 like scripting language. A radio mapping algorithm which uses controllable noise sources spaced across the grid to emulate the effect of physical distance is used to map real-world wireless network scenarios to specific nodes in the grid.

For the container migration evaluation at scale, we use ORBIT testbed for our experimentation.

Read more about ORBIT [here](http://www.orbit-lab.org).

#### Steps ####
- Reserve ORBIT resources
- Set-up resources
- Carry out experiment
- Collect results
- Release resources

## Procedure ##
1. Reserve resources on the ORBIT. We use SB4 for the tests and Grid for final evaluation. 
2. Load the image to bring up Docker, CRIU and other dependencies:
```
omf load -i containerlm.ndz -t all
omf tell -a on -t all
```

The image `containerlm1.ndz` is created as follows:

a. Load baseline image for Ubuntu 16.04 on the ORBIT testbed (we used SB4 here and node1-1 to create the final image):
```
omf load -i baseline-ubuntu-16-04-64bit.ndz -t node1-1
```

b. SSH to node1-1 from SB4 console:
```
ssh root@node1-1
```

c. Install CRIU version 2.6 on node1-1:
```
sudo apt-get update
sudo apt-get install criu
```

d. Install Docker version 19.03.5:
```
$ sudo apt-get update
$ sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo apt-key fingerprint 0EBFCD88
$ sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
$ sudo apt-get update
$ sudo apt-get install docker-ce
```

e. Install additional required packages (like the one for `mpstat`)
```
sudo apt-get install sysstat iperf3 stress
```

f. Clone/Pull this repository:
```
git clone https://github.com/FFrabetti/Cooperative-container-migration.git
```

g. Follow the instructions in [this page](registry_config.md) to create and distribute a certificate for your Certificate Authority.

h. Run the prepare script to make it ready for imaging:
```
$ bash prepare.sh
```

i. From the console of SB4, run the following command to save the image:
```
$ omf save -n node1-1.sb4.orbit-lab.org
```

h. When the image is saved, note down its name and eventually re-name it for better management, or create a link called `containerlm.ndz` with the most up-to-date version.

## At startup ##
1. Login to the node and run the set-up script:
```
ssh root@node1-1
bash setup.sh
```
The script will pull the latest changes from the repository and create executables in the /root/bin directory.

2. Set IP and netmask in all available nodes for `eth0`
```
# check node eth0 IP
ip a show up dev eth0 | grep 'inet ' 	# | cut -d/ -f1 | cut -c 10-
```

3. Create signed certificates for all the nodes that require a Docker Registry (see [here](registry_config.md)).

4. Follow experiment-dependent preparatory instructions

## Collecting measurements ##
Each machine has two wired network interfaces, `eth0` and `eth1`: we are using the latter for control traffic related to the experiment (ssh, messages exchanged with the `console`, etc.), and the former for the experiment itself.

For each node, we are monitoring its workload with `mpstat` every second and the traffic through `eth0` with `tcpdump`. Use:

```
measureLoad.sh loadTime_in_seconds fileName
```
To append to the given file the idle percentage (with timestamp) every period, and:

```
measureTrafficIn.sh
measureTrafficOut.sh
```
to write to `testin.txt` (or `testout.txt`) the output of `tcpdump` on `eth0` for in/out-ward traffic.
