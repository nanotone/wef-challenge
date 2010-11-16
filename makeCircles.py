if __name__ == "__main__":
	f = open("Circles.as", "w")
	f.write("""package {
public class Circles {
""")
	lines = [l.strip() for l in open("naming_convention.txt").readlines()]
	for line in lines:
		f.write("""[Embed(source="circles/%s_Countries.gif")]
public var %s_Countries:Class;

[Embed(source="circles/%s_Orgs.gif")]
public var %s_Orgs:Class;

""" % (line, line, line, line))
	f.write("""}}""")
