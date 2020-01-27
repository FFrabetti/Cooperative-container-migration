#!/bin/bash

len=$1
rangemin=$2
rangemax=$3

range=$((rangemax - rangemin + 1))

while [ $len -gt 0 ]; do
	echo $((RANDOM % range + rangemin))
	len=$((len - 1))
done
