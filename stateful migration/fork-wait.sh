#!/bin/bash

# associative array for job status
declare -A JOBS

# run command in the background
# cmd & JOBS[$!]="cmd"

# wait and check exit status of each job
# returns 1 if any job failed
function waitall {
	local cmd
	local status=0
	for pid in ${!JOBS[@]}; do # iterate over keys
		cmd=${JOBS[${pid}]}
		wait ${pid}
		local res=$?
		JOBS[${pid}]=$res
		
		if [[ $res -ne 0 ]]; then
			status=$res
			echo -e "[${pid}] Exited with status: ${status}\t${cmd}"
		fi
	done
	
	return ${status}
}

# { list; } group a list of commands without creating a subshell
# the spaces and the semicolon (or newline) following list are required
{ sleep 1; false; }    & JOBS[$!]="sleep 1"
{ sleep 3; true; }     & JOBS[$!]="sleep 3"
{ sleep 2; exit 5; }   & JOBS[$!]="sleep 2"
{ sleep 5; true; }     & JOBS[$!]="sleep 5"

echo "while they execute, the parent can do other things"

waitall || echo "Some jobs failed!"

echo "after termination"
