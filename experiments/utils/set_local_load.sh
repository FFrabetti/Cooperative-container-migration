#!/bin/bash

source config.sh || { echo "config.sh not found"; exit 1; }

loadlevel=$1
timeout=$2

stress -c $loadlevel -t $timeout &
runningBackground "stress"
