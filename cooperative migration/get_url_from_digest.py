#!/usr/bin/python3
import sys, json;

if len(sys.argv) != 2:
    sys.exit("1 argument expected: <digest>")

digest = sys.argv[1]

data = json.load(sys.stdin)

for layer in data["layers"]:
    if digest == layer["digest"] and "urls" in layer and len(layer["urls"]) > 0:
        urls = layer["urls"]
        # #### policy ####
        url = urls[0]
        # #### #### ####
        print(url)
        break
