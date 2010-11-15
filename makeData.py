import json

def dumpToFlex(obj):
	f = open("Data.as", "w")
	f.write("""package {
public class Data {
	public static var data:Object = """)
	json.dump(obj, f, indent=4, encoding="latin-1")
	f.write(""";
}}""")

if __name__ == "__main__":
	dumpToFlex({
		"yang": ["tina"],
		"tina": ["clint"],
		"clint": ["gene2"],
		"gene2": ["gene3"],
		"gene3": ["evil_gene"],
		"evil_gene": ["gene"],
		"gene": ["tina", "clint", "yang"],
	})



