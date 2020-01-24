#!/bin/bash

source ./config.sh

loadlevel=$1
timeout=$2

stress -c $loadlevel -t $timeout &
runningBackground "stress"
