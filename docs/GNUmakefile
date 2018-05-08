SRC_DIRS := src

#OUTDIR := $(CURDIR)
OUTDIR := outputs

#SOURCES := $(foreach DIR,$(SRC_DIRS),$(wildcard $(DIR)/*.m4))

export VPATH := $(foreach DIR, $(SRC_DIRS), $(DIR))

SOURCES := $(foreach DIR,$(SRC_DIRS), $(notdir $(wildcard $(DIR)/*.m4)))

OUTPUTS := $(SOURCES:%.m4=$(OUTDIR)/%.md)
PDFS := $(OUTPUTS:%.md=%.pdf)


.PHONY : all
all : all_pre $(OUTPUTS)
	@#

.PHONY : all_pre
all_pre :
	@mkdir -p $(OUTDIR)

.PHONY : pdfs
pdfs : pdfs_pre $(PDFS)
	@#

.PHONY : pdfs_pre
pdfs_pre : all_pre $(OUTPUTS)
	@#

#all_pre :
#	mkdir -p $(OUTDIR) $(DEPDIR)
#	@for ofile in $(OUTPUTS); \
#	do \
#		mkdir -p $$(dirname $$ofile); \
#	done

$(OUTPUTS) : $(OUTDIR)/%.md : %.m4
	m4 $< > $@


$(PDFS) : %.pdf : %.md
	md2pdf $< > $@

.PHONY : clean
clean :
	rm -rfv $(OUTPUTS) $(PDFS)
