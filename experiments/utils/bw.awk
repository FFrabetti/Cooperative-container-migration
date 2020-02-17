BEGIN {
	args=""
	bwfile=""
	i=0
}

{
	if($1 != args || $2 != bwfile) {
		i+=1
		args=$1
		bwfile=$2
		vargs[i]=args
		vfiles[i]=bwfile
	}
	count[i]+=1
	tot[i]+=$4
}

END {
	for(key in count)
		print key, vargs[key], vfiles[key], count[key], (tot[key] / count[key])
}
