#!/usr/bin/python3
import sys, json, os;

if len(sys.argv) != 2:
    sys.exit("1 argument expected: <work_dir>")

work_dir = sys.argv[1]

# input: manifest (JSON) -> load to python
#with open("data_file.json", "r") as read_file:
#    data = json.load(read_file)
data = json.load(sys.stdin)

# for each layer, set field "urls" (array/list) with the content from layer["digest"].txt
for layer in data["layers"]:   
# clear list first
#   if "urls" not in layer:
    layer["urls"] = []
    urls = layer["urls"]

    filepath = work_dir + "/" + layer["digest"] + ".txt"
    if os.path.exists(filepath):
        with open(filepath, "r") as f:
            for line in f:
                line = line.strip() # remove leading/trailing whitespaces
                if line not in urls:
                    urls.append(line)
    else:
        print(filepath + " not found", file=sys.stderr)
        
# print updated manifest (-> JSON)
#with open("data_file.json", "w") as write_file:
#    json.dump(data, write_file)
print(json.dumps(data))
