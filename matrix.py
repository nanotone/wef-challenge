import json
import re

def cleanup(text): return re.sub(r'[^\w\.]+', "_", text)

def cleanupMatch(match): return cleanup(match.group(1))

def csvSplit(line):
	line = line.strip()
	line = re.sub(r'"([^"]+)"', cleanupMatch, line)
	return [cleanup(cell) for cell in line.split(",")]

matrix = [csvSplit(line) for line in open("matrix2.csv")]


rows = [ {"name": row[0], "data": row[1:] } for row in matrix[1:]]

columns = []
for (i, name) in enumerate(matrix[0][1:]):
	outbound = []
	columnData = {"name": name, "outbound": outbound}
	for row in rows:
		score = float(row["data"][i])
		if score > 0.5:
			outbound.append([row["name"], score])
	columns.append(columnData)

print json.dumps(columns, indent=4)
