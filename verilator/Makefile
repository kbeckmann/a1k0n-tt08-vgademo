TARGETS = recip16 cordic2step vgademo donuthit audiotrack
VERILATOR = verilator
VERILATOR_FLAGS = -Wall --trace -cc --exe -I../src
CPP = g++
CPP_FLAGS = -std=c++11 -Wall

all: $(TARGETS)

vgademo: ../src/vgademo.v ../src/recip16.v ../src/donuthit.v ../src/donut.v ../src/cordic2step.v ../src/rom.v ../src/step3vec.v ../src/audiotrack.v ../src/songrom.v vgademo_tb.cpp
#vgademo: ../src/vgademo.v ../src/recip16.v ../src/donuthit.v ../src/donut.v ../src/cordic2reduce.v ../src/rom.v ../src/step3reduce.v vgademo_tb.cpp
#vgademo: ../src/vgademo.v ../src/recip16.v ../src/rom.v vgademo_tb.cpp
	$(VERILATOR) -Wno-widthexpand -Wno-widthtrunc --trace -cc --exe $^ -CFLAGS "-g -O3" --LDFLAGS "-lSDL2" --top-module vgademo
	$(MAKE) -C obj_dir -f V$@.mk
	cp obj_dir/V$@ $@

audiotrack: ../src/audiotrack.v ../src/songrom.v audiotrack_tb.cpp
	$(VERILATOR) -Wno-widthexpand -Wno-widthtrunc --trace -cc --exe $^ -CFLAGS "-g -O3" --LDFLAGS "-lSDL2" --top-module audiotrack
	$(MAKE) -C obj_dir -f V$@.mk
	cp obj_dir/V$@ $@

%: ../src/%.v %_tb.cpp
	$(VERILATOR) $(VERILATOR_FLAGS) $< $*_tb.cpp
	$(MAKE) -C obj_dir -f V$@.mk
	cp obj_dir/V$@ $@

clean:
	rm -rf obj_dir
	rm -f $(TARGETS)
	rm -f *.vcd

.PHONY: all clean
