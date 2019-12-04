#!/usr/bin/python3
import sys, json, os;

if len(sys.argv) < 3:
    sys.exit("At least 2 arguments expected: <digest> <url> [<url>...]")

digest = sys.argv[1]
# url = sys.argv[2]

data = json.load(sys.stdin)

added = False
for layer in data["layers"]:   
    if layer["digest"] == digest:
        if "urls" not in layer:
            layer["urls"] = []
            
        for url in sys.argv[2:]:
            if url not in layer["urls"]:
                layer["urls"].append(url)
                added = True
        break        

print(json.dumps(data))

if not added:
    sys.exit(1) # error
# at default it exits with 0 (success)
