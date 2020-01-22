#!/bin/bash
loadlevel=$1
timeout=$2
stress -c $loadlevel -t $timeout
