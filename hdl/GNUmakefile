# verilog
# m4_verilog
# start stuff

# Edit these variables if more directories are needed.
SRC_DIRS := src

#end stuff

# Prefix for output file name (change this if needed!)
#PROJ := $(shell basename $(CURDIR))
PROJ := frost32_cpu

# (System)Verilog Compiler
VC=iverilog


BUILD_VVP=$(VC) -o $(PROJ).vvp
#BUILD_VHDL=$(VC) -tvhdl -o $(PROJ).vhd
PREPROCESS=$(VC) -E -o $(PROJ).E

# Generated directories
V_OUT_DIR := v_outputs


M4_SRC_FILES := $(foreach DIR,$(SRC_DIRS),$(wildcard $(DIR)/*.src.m4.v))
SRC_FILES := $(M4_SRC_FILES:%.src.m4.v=$(V_OUT_DIR)/%.src.v)

.PHONY : all
all: clean reminder all_pre $(PKG_FILES) $(SRC_FILES)
	$(BUILD_VVP) $(PKG_FILES) $(SRC_FILES)
	@#$(BUILD_VHDL) $(PKG_FILES) $(SRC_FILES)

.PHONY : only_preprocess
only_preprocess: clean reminder all_pre $(PKG_FILES) $(SRC_FILES)
	$(PREPROCESS) $(PKG_FILES) $(SRC_FILES)

.PHONY : all_pre
all_pre :
	mkdir -p $(V_OUT_DIR)
	@for src_file in $(SRC_FILES); \
	do \
		mkdir -p $$(dirname $$src_file); \
	done

$(SRC_FILES) : $(V_OUT_DIR)/%.src.v : %.src.m4.v
	m4 $< > $@

.PHONY : reminder
reminder:
	@#

.PHONY : clean
clean:  
	rm -rf $(PROJ).vvp $(PROJ).vhd $(PROJ).E $(V_OUT_DIR)
