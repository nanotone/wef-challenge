cc := /Users/yang/Downloads/flex_sdk_4/bin/mxmlc 
#devel := /Users/yang/dev/wef-challenge

swfs += WEF.swf

all: $(swfs)

%.swf: *.as *.py
	@echo "exporting data to Data.as"
	python matrix.py
	@echo "generating Circles.py"
	python makeCircles.py
	$(cc) -incremental=true -source-path=. -static-link-runtime-shared-libraries=true $*.as 
	#scp WEF.swf yang@quarklet.com:tmp/
	#cp $@ $(devel)/

