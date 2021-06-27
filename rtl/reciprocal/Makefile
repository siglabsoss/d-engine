.PHONY: all build verilate compile run show

all: build verilate compile run show

clean:
	rm hdl/*
	rm -rf obj_dir

build:
	npm run build
	./bin/gen-reciprocal.js
	npm run redot

verilate:
	verilator \
	-Wno-WIDTH \
	-Wno-PINMISSING \
	--trace \
	-cc \
	-O3 \
	-Ihdl \
	--top-module reciprocal \
	--exe hdl/tb.cpp \
	hdl/*.v

compile:
	make -j -C obj_dir/ -f Vreciprocal.mk Vreciprocal

run:
	./obj_dir/Vreciprocal

show:
	gtkwave ./reciprocal.vcd -S hdl/top-wave.tcl &
