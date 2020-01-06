#!/bin/bash

CONTAINER=$1

docker container inspect $CONTAINER --format='{{range $m := .Mounts}}{{if eq $m.Type "volume"}}{{$m.Name}} {{$m.Destination}} {{$m.RW}}{{end}}
{{end}}' | while read name destination rw; do
	# get attributes (labels and options) for each volume (docker volume inspect)
	# no empty lines
	[ $name ] && echo $name "$destination" $rw $(docker volume inspect $name \
		--format='{{range $l,$v := .Labels}}volume-label={{$l}}={{$v}},{{end}} {{range $o,$v := .Options}}volume-opt={{$o}}={{$v}},{{end}}')
done
