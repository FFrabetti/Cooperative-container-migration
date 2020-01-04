# Container Migration Set-up on ORBIT #

The ORBIT open access testbed for next-generation wireless networking at Rutgers University, developed under the National Science Foundation’s NRT (Network Research Testbeds) program addresses the challenge of supporting realistic and reproducible wireless networking experiments at scale.  

The ORBIT large-scale radio grid emulator consists of an array of ~20x20 open-access programmable nodes each with multiple 802.11a,b,g or other (Bluetooth, Zigbee, GNU) radio cards. The radio nodes are connected to an array of backend servers over a switched Ethernet network, with separate physical interfaces for data, management and control.  Interference sources and spectrum monitoring equipment are also integrated into the radio grid.  Users of the grid emulator system log into an experiment management server which executes experiments involving network topologies and protocol software specified using an ns2 like scripting language. A radio mapping algorithm which uses controllable noise sources spaced across the grid to emulate the effect of physical distance is used to map real-world wireless network scenarios to specific nodes in the grid.

For the container migration evaluation at scale, we use ORBIT testbed for our experimentation.

Read more about ORBIT [here](http://www.orbit-lab.org).

#### Steps ####
- Reserve ORBIT resources
- Set-up resources
- Carry out migration experiment
- Collect results
- Release resource

#### Use-cases ####
- Stateless migration 
- Stateful migration

For both these cases, we evaluate following schemes.
- Centralized Traditional Container Migration (CTCM)
- Centralized Layered Container Migration (CLCM)
- Distributed Layered Container Migration (DLCM)

## Procedure ##
1. Reserve resources on the ORBIT. We use SB4 for the tests and Grid for final evaluation. 
2. Load the image to bring up Docker, CRIU and other dependencies:
```
omf load -i containerlm1.ndz -t all
omf tell -a on -t all
```
3. Login to the node1-1 and node1-2 to run the set-up script:
```
ssh root@node1-1
bash setup.sh
```
The setup script will create executables in the /root/bin directory. 

4. Follow the steps listed on the [this page] (./trafficgen.md) to test the applications.


