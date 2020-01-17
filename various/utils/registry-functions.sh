#!/bin/bash

function curl_test_ok {
	# -s silent, -L follow redirects, -I HEAD, -w custom output format, -o redirect HTML
	# see also: --connect-timeout <CT>, --max-time <MT>
	local output="/dev/null"
	if [ $# -eq 2 ]; then
		output="$2"
	fi
	[ $(curl -sLI -w '%{http_code}' "$1" -o "$output") == "200" ]
}

function getManifest { # REGISTRY (REPOSITORY TAG | REPO:TAG)
	local repo=$2
	local tag=$3
	if [ $# -eq 2 ]; then
		repo=$(echo $2 | cut -d: -f1)
		tag=$(echo $2 | cut -d: -f2)
	fi

	curl -sS $1/v2/$repo/manifests/$tag \
		-H "Accept: application/vnd.docker.distribution.manifest.v2+json"		
}

function getLayersDigests {
	python3 -c "import sys, json;
for l in json.load(sys.stdin)['layers']:
	print(l['digest'])"
}

function getRepositories {
	curl -sS $1/v2/_catalog | python3 -c "import sys, json;
for r in json.load(sys.stdin)['repositories']:
	 print(r)"
}

function getLayer {
	local url=${1%$'\r'}
	curl -sS "$url" \
		-H "Accept: application/vnd.docker.image.rootfs.diff.tar.gzip"
}

function getUploadUrl {
	local content_type="application/vnd.docker.image.rootfs.diff.tar.gzip" # layer
	if [ $# -eq 3 ]; then
		content_type="application/vnd.docker.container.image.v1+json" # config
	fi

	local res=$(curl -sS "$1/v2/$2/blobs/uploads/" \
		-I -X POST \
		-H "Accept: $content_type" \
		-w "%{http_code}")
	
	# if 202 Accepted response, the upload URL is returned in the Location header
	local res_code=$(echo "$res" | tail -1)
	[ "$res_code" = "202" ] && { echo "$res" | grep Location | cut -d" " -f2; }
}

function getConfigDigestSize {
	python3 -c "import sys, json;
c = json.load(sys.stdin)['config']
print(c['digest'], c['size'])"
}

function getConfig {
	curl -sS $1/v2/$2/blobs/$3 \
		-H "Accept: application/vnd.docker.container.image.v1+json"
}

function pushLayer { # UPLOAD_URL DIGEST LEN [FROM_FILE]
	local url=${1%$'\r'}
	local symbol="?"
	if [[ $1 =~ "?" ]]; then
		symbol="&"
	fi
	
	local lfile="@-"
	if [ $# -eq 4 ]; then
		lfile="@$4"
	fi

	curl -sS "$url${symbol}digest=$2" \
		-X PUT \
		-H "Content-Length: $3" \
		-H "Range: 0-$3" \
		-H "Content-Type: application/octet-stream" \
		--data-binary "$lfile"		# @filename
	
	# 201 Created response
	# - Location: registry URL to access the accepted layer file
	# - Docker-Content-Digest: canonical digest of the uploaded blob, which may differ from the provided digest
}

function blobMount {
	curl -sS "$1/v2/$2/blobs/uploads/?mount=$3&from=$4" \
		-I -X POST \
		-H "Content-Length: 0"
}

function pushConfig {
	local url=${1%$'\r'}
	local symbol="?"
	if [[ $1 =~ "?" ]]; then
		symbol="&"
	fi
	
	local cfile="@-"
	if [ $# -eq 4 ]; then
		cfile="@$4"
	fi

	curl -sS "$url${symbol}digest=$2" \
	-X PUT \
	-H "Content-Length: $3" \
	-H "Range: 0-$3" \
	-H "Content-Type: application/octet-stream" \
	--data "$cfile"
}

function pushManifest { # REGISTRY REPO VERS [FROM_FILE]
	local mfile="@-"
	if [ $# -eq 4 ]; then
		mfile="@$4"
	fi

	curl -sS "$1/v2/$2/manifests/$3" \
	-X PUT \
	-H "Content-Type: application/vnd.docker.distribution.manifest.v2+json" \
	--data "$mfile"
}

function getRepoTags {
	curl -sS "$1/v2/$2/tags/list" | python3 -c "import sys, json;
for t in json.load(sys.stdin)['tags']:
	print(t)"
}
