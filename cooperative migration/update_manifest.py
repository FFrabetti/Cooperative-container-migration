#!/usr/bin/python3
import sys, json, os;

if len(sys.argv) != 3:
    sys.exit("2 argument expected: <digest> <url>")

digest = sys.argv[1]
url = sys.argv[2]

data = json.load(sys.stdin)

added = False
for layer in data["layers"]:   
    if layer["digest"] == digest:
        if "urls" in layer:
            if url not in layer["urls"]:
                layer["urls"].append(url)
                added = True
        else:
            layer["urls"] = [url]
            added = True
        break        

print(json.dumps(data))

if not added:
    sys.exit(1) # error
# at default it exits with 0 (success)
