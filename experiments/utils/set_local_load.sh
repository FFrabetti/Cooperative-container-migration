#!/bin/bash

source ./config.sh

loadlevel=$1
timeout=$2

beforeBackground "setLoad.pid"
stress -c $loadlevel -t $timeout &
afterBackground "setLoad.pid" $!
