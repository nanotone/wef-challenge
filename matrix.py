import re

COMMA = "<COMMA>"

def csvSplit(line):
	line = line.strip()
	line = re.sub(r'"([^"]+)"', (lambda m: m.group(1).replace(",", COMMA)), line)
	return [cell.replace(COMMA, ",") for cell in line.split(",")]

matrix = [csvSplit(line) for line in open("matrix2.csv")]

def tokenize(text): return re.sub(r'[^\w\.]+', "_", text)

rows = [ {"token": tokenize(row[0]), "data": row[1:] } for row in matrix[1:]]

nodes = {}
for (i, name) in enumerate(matrix[0][1:]):
	outbound = []
	nodeData = {"name": name, "outbound": outbound}
	for row in rows:
		score = float(row["data"][i])
		if score > 0.0:
			outbound.append([row["token"], score])
	nodes[tokenize(name)] = nodeData

#import json
#print json.dumps(columns, indent=4)

import makeData
makeData.dumpToFlex(nodes)
