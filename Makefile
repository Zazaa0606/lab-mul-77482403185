# Lab 2 - Makefile for the mul16 starter project
TOP    = mul16
TB_TOP = tb_mul16_smoke
RTL := $(wildcard rtl/*.sv)
TB  := $(wildcard tb/*.sv)
A ?= 13
B ?= 11
W ?= 4

help:
	@echo "Targets: help lint sim sim-icarus wave trace clean logs"

lint:
	verilator --lint-only -Wall -Wno-fatal --top-module $(TOP) $(RTL)

sim:
	mkdir -p sim
	verilator --binary --timing --trace -Wno-fatal -j 0 --top-module $(TB_TOP) -Mdir sim/obj $(RTL) $(TB)
	./sim/obj/V$(TB_TOP)

sim/$(TB_TOP).vvp: $(RTL) $(TB)
	mkdir -p sim
	iverilog -g2012 -s $(TB_TOP) -o $@ $^

sim-icarus: sim/$(TB_TOP).vvp
	vvp -n $<

wave:
	gtkwave sim/dump.vcd &

trace:
	python3 sw/model/mul_model.py $(A) $(B) --w $(W)

clean:
	rm -rf sim

logs:
	tclsh sw/scripts/tong_hop_log.tcl

.PHONY: help lint sim sim-icarus wave trace clean logs