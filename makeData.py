import json

f = open("Data.as", "w")
f.write("""package {
public class Data {
	public static var data:Object = """)

obj = {
	"yang": ["tina"],
	"tina": ["clint"],
	"clint": ["gene2"],
	"gene2": ["gene3"],
	"gene3": ["evil_gene"],
	"evil_gene": ["gene"],
	"gene": ["tina", "clint", "yang"],
}

json.dump(obj, f, indent=4)

f.write(""";
}}""")

