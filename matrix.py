import pprint

###############################################################################

categoryExport = {}
currentCategory = None
currentArray = []
for line in open("categories2.txt"):
	line = line.strip()
	if not currentCategory:
		currentCategory = line
		currentArray = []
		continue
	if line:
		pieces = line.split(" ", 1)
		currentArray.append(pieces[1])
	else:
		categoryExport[currentCategory] = currentArray
		currentCategory = None
if currentCategory:
	categoryExport[currentCategory] = currentArray
	currentCategory = None

###############################################################################

import re

COMMA = "<COMMA>"
QUOTE = "<QUOTE>"

def csvSplit(line):
	line = line.strip()
	line = line.replace('""', QUOTE)
	line = re.sub(r'"([^"]+)"', (lambda m: m.group(1).replace(",", COMMA)), line)
	return [cell.replace(COMMA, ",").replace(QUOTE, '"') for cell in line.split(",")]

matrix = [csvSplit(line) for line in open("matrix2.csv")]

def tokenize(text): return re.sub(r'[^\w\.]+', "_", text)
def canonicize(name):
	if ("Women" in name) and ("Empowerment" in name): return "Women's Empowerment"
	if "Chronic Diseases" in name: return "Chronic Diseases & Conditions"
	if ("Ecosystems" in name) and ("Biodiversity" in name): return "Ecosystems & Biodiversity Loss"
	return name

rows = [ {"token": tokenize(row[0]), "data": row[1:] } for row in matrix[1:]]

nodeList = []
for (i, name) in enumerate(matrix[0][1:]):
	outbound = []
	nodeData = {"name": name, "outbound": outbound, 'token': tokenize(name)}
	for row in rows:
		score = float(row["data"][i])
		if score > 0.0:
			outbound.append({'token': row["token"], 'score': score})
	#nodeList.append(nodeData)
	for catKey in categoryExport:
		catList = categoryExport[catKey]
		try:
			catList[catList.index(name)] = nodeData
			break
		except ValueError: pass
	else:
		print name, "council not found in any category"

#pprint.pprint(categoryExport)
#sys.exit()

###############################################################################

comments = [csvSplit(line) for line in open("comments2.csv")]
commentsDict = {}
for row in comments[1:]:
	srcName = tokenize(canonicize(row[0]))
	for i in range(3, len(row)-1, 2):
		dstName = tokenize(canonicize(row[i]))
		comment = row[i+1].strip()
		if comment:
			#print "%s-%s: %s" % (srcName, dstName, comment)
			commentsDict["%s-%s" % (srcName, dstName)] = comment
	#print ""


import makeData
makeData.dumpToFlex({'categoryExport': categoryExport, 'comments':commentsDict})
