SRC_DIRS := src

OUTDIR := $(CURDIR)

#SOURCES := $(foreach DIR,$(SRC_DIRS),$(wildcard $(DIR)/*.m4))

export VPATH := $(foreach DIR, $(SRC_DIRS), $(DIR))

SOURCES := $(foreach DIR,$(SRC_DIRS), $(notdir $(wildcard $(DIR)/*.m4)))

OUTPUTS := $(SOURCES:%.m4=$(OUTDIR)/%.md)


.PHONY : all
all : all_pre $(OUTPUTS)
	@#

.PHONY : all_pre
all_pre :
	@mkdir -p $(OUTDIR)

#all_pre :
#	mkdir -p $(OUTDIR) $(DEPDIR)
#	@for ofile in $(OUTPUTS); \
#	do \
#		mkdir -p $$(dirname $$ofile); \
#	done

$(OUTPUTS) : $(OUTDIR)/%.md : %.m4
	m4 $< > $@

.PHONY : clean
clean :
	rm -rfv $(OUTDIR)
