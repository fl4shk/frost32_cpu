# These directories specify where source code files are located.
# Edit these variables if more directories are needed.  
# Separate each entry by spaces.


SHARED_SRC_DIRS:=src \
	src/gen_src \
	src/liborangepower_src \

CXX_DIRS:=$(SHARED_SRC_DIRS)
# End of source directories


# Whether or not to do debugging stuff
#DEBUG:=yeah do debug

DEBUG_OPTIMIZATION_LEVEL:=-O0
REGULAR_OPTIMIZATION_LEVEL:=-O2

ASSEMBLER_GRAMMAR_PREFIX:=AssemblerGrammar
DISASSEMBLER_GRAMMAR_PREFIX:=DisassemblerGrammar

ALWAYS_DEBUG_SUFFIX:=_debug
ifdef DEBUG
	DEBUG_SUFFIX:=$(ALWAYS_DEBUG_SUFFIX)
endif

# This is the name of the output file.  Change this if needed!
#PROJ:=$(shell basename $(CURDIR))$(DEBUG_SUFFIX)
PROJ:=frost32_cpu_assembler_disassembler$(DEBUG_SUFFIX)


# Compilers and initial compiler flags
CXX:=$(PREFIX)g++
CXX_FLAGS:=$(CXX_FLAGS) -std=c++17 -Wall \
	$(shell pkg-config --cflags jsoncpp)

LD:=$(CXX)

# Initial linker flags
LD_FLAGS:=$(LD_FLAGS) -lm \
	-lantlr4-runtime \
	-ljsoncpp \



ifdef DEBUG
	EXTRA_DEBUG_FLAGS:=-g
	DEBUG_FLAGS:=-gdwarf-3 $(EXTRA_DEBUG_FLAGS)
	EXTRA_LD_FLAGS:=$(DEBUG_FLAGS)
	OPTIMIZATION_LEVEL:=$(DEBUG_OPTIMIZATION_LEVEL)
else
	OPTIMIZATION_LEVEL:=$(REGULAR_OPTIMIZATION_LEVEL)
endif




FINAL_BASE_FLAGS:=$(OPTIMIZATION_LEVEL) \
	$(EXTRA_BASE_FLAGS) $(EXTRA_DEBUG_FLAGS)

# Final compiler and linker flags
CXX_FLAGS:=$(CXX_FLAGS) $(FINAL_BASE_FLAGS)
LD_FLAGS:=$(LD_FLAGS) $(EXTRA_LD_FLAGS) $(COMMON_LD_FLAGS)




# Generated directories
OBJDIR:=objs$(DEBUG_SUFFIX)
DEPDIR:=deps$(DEBUG_SUFFIX)
PREPROCDIR:=preprocs$(DEBUG_SUFFIX)




CXX_SOURCES:=$(foreach DIR,$(CXX_DIRS),$(wildcard $(DIR)/*.cpp))
CXX_OFILES:=$(CXX_SOURCES:%.cpp=$(OBJDIR)/%.o)
CXX_PFILES:=$(CXX_SOURCES:%.cpp=$(DEPDIR)/%.P)


# Compiler-generated files
# OFILES are object code files (extension .o)
OFILES:=$(CXX_OFILES)
# PFILES are used for automatic dependency generation
PFILES:=$(CXX_PFILES)

# Preprocessed output of C++ and/or C files
CXX_EFILES:=$(CXX_SOURCES:%.cpp=$(PREPROCDIR)/%.E)
EFILES:=$(CXX_EFILES)

MODIFED_GENERATED_SOURCES:=
FINAL_GENERATED_SOURCES:=src/gen_src/$(ASSEMBLER_GRAMMAR_PREFIX)Parser.h \
	src/gen_src/$(DISASSEMBLER_GRAMMAR_PREFIX)Parser.h 
GENERATED_SOURCES:=$(MODIFED_GENERATED_SOURCES) \
	$(FINAL_GENERATED_SOURCES)

.PHONY : all
all : all_pre $(MODIFED_GENERATED_SOURCES)
	@$(MAKE) final_generated

.PHONY : final_generated
final_generated : all_pre $(FINAL_GENERATED_SOURCES)
	@$(MAKE) non_generated

.PHONY : non_generated
non_generated : all_pre $(OFILES)
	$(LD) $(OFILES) -o $(PROJ) $(LD_FLAGS)



# all_objs is ENTIRELY optional
.PHONY : all_objs
all_objs : all_pre $(OFILES)
	@#




.PHONY : all_pre
all_pre :
	mkdir -p $(OBJDIR) $(DEPDIR) src/gen_src/
	@for ofile in $(OFILES); \
	do \
		mkdir -p $$(dirname $$ofile); \
	done
	@for pfile in $(PFILES); \
	do \
		mkdir -p $$(dirname $$pfile); \
	done




.PHONY : grammar_stuff
grammar_stuff : src/gen_src/$(ASSEMBLER_GRAMMAR_PREFIX)Parser.h \
	src/gen_src/$(DISASSEMBLER_GRAMMAR_PREFIX)Parser.h
	@#

src/gen_src/$(ASSEMBLER_GRAMMAR_PREFIX)Parser.h : src/$(ASSEMBLER_GRAMMAR_PREFIX).g4
	if [ ! -d src/gen_src ]; then make all_pre; fi; \
	cp src/$(ASSEMBLER_GRAMMAR_PREFIX).g4 src/gen_src && cd src/gen_src \
	&& antlr4 -no-listener -visitor -Dlanguage=Cpp $(ASSEMBLER_GRAMMAR_PREFIX).g4 \
	&& rm $(ASSEMBLER_GRAMMAR_PREFIX).g4
src/gen_src/$(DISASSEMBLER_GRAMMAR_PREFIX)Parser.h : src/$(DISASSEMBLER_GRAMMAR_PREFIX).g4
	if [ ! -d src/gen_src ]; then make all_pre; fi; \
	cp src/$(DISASSEMBLER_GRAMMAR_PREFIX).g4 src/gen_src && cd src/gen_src \
	&& antlr4 -no-listener -visitor -Dlanguage=Cpp $(DISASSEMBLER_GRAMMAR_PREFIX).g4 \
	&& rm $(DISASSEMBLER_GRAMMAR_PREFIX).g4

# Here's where things get really messy. 
$(CXX_OFILES) : $(OBJDIR)/%.o : %.cpp
	@echo $@" was updated or has no object file.  (Re)Compiling...."
	$(CXX) $(CXX_FLAGS) -MMD -c $< -o $@
	@cp $(OBJDIR)/$*.d $(DEPDIR)/$*.P
	@rm -f $(OBJDIR)/$*.d




-include $(PFILES)

#¯\(°_o)/¯

.PHONY : only_preprocess
only_preprocess : only_preprocess_pre $(EFILES)

.PHONY : only_preprocess_pre
only_preprocess_pre :
	mkdir -p $(DEPDIR) $(PREPROCDIR)
	@for efile in $(EFILES); \
	do \
		mkdir -p $$(dirname $$efile); \
	done


$(CXX_EFILES) : $(PREPROCDIR)/%.E : %.cpp
	$(CXX) $(CXX_FLAGS) -MMD -E $< -o $@
	@cp $(PREPROCDIR)/$*.d $(DEPDIR)/$*.P
	@rm -f $(PREPROCDIR)/$*.d



.PHONY : clean
clean :
	rm -rfv $(OBJDIR) $(DEPDIR) $(ASMOUTDIR) $(PREPROCDIR) $(PROJ) tags *.taghl gmon.out $(GENERATED_SOURCES) src/gen_src


