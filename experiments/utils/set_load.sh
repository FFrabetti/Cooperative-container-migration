#!/bin/bash
#needs input file with incidence matrix of delay values
source ./config.sh
echo "Input load value between 1-10 and timeout in seconds"
ssh -o StrictHostKeyChecking=no root@$nodesrc "bash set_load_local.sh $1 $5 &"
ssh -o StrictHostKeyChecking=no root@$nodedst "bash set_load_local.sh $2 $5 &"
ssh -o StrictHostKeyChecking=no root@$nodeone "bash set_load_local.sh $3 $5 &"
ssh -o StrictHostKeyChecking=no root@$nodetwo "bash set_load_local.sh $4 $5 &"
