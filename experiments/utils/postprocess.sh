#!/bin/bash

currdir=$(pwd)

for dir in "$@"; do
	cd $dir
	pwd
	bash process_data.sh 	# creates pr.* files
	bash test.sh pr.* > results.txt
	
	awk '{ line=""; for(i=1; i<=NF; i++) { if(i>1) line=line ","; line=line $i }; print line }' < results.txt > results.csv
	
	cd $currdir
done
