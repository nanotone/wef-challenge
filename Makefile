cc := /Users/yang/Downloads/flex_sdk_4/bin/mxmlc 
#devel := /Users/yang/dev/wef-challenge

swfs += WEF.swf

all: $(swfs)

%.swf: *.as makeData.py
	@echo "exporting data to Data.as"
	python makeData.py
	$(cc) -incremental=true -source-path=. -static-link-runtime-shared-libraries=true $*.as 
	#cp $@ $(devel)/

