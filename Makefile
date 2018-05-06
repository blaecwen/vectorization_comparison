# -------------------------------------
# Values to be changed

# number of rows to generate for input_file
ROWS=1000000

# random seed for rows generetad for input_file
RANDOM_SEED=7


# first number of input rows for experiment
EXP_RANGE_BEGIN=100000

# Incrementation step of input rows number for the experiment
# 	NOTE: should be multiple of 4
EXP_STEP=100

# Number of different input rows number used in the experiment 
# (It is the number of time points produced for each executable)
EXP_STEPS_NUMBER=10

# Number of probes with the same input rows number
EXP_PROBES=10

#-------------------------------------

CXX_PROGS = valarray 
CC_PROGS = gcc_vector normal

RESULTS_DIR=results
DATA_FILE=data.txt
RES_CSV_FILE=experiments.csv

SRC_DIR=src
CC=gcc
CXX=g++
override CFLAGS+=-I$(SRC_DIR)
override ASMFLAGS+=-g -fverbose-asm

ODIR=obj
BINDIR=bin
ASMDIR=asm

_OBJ = normal.o 
OBJ = $(patsubst %,$(ODIR)/%,$(_OBJ))


all: build generate_data run_experiments

build: $(CXX_PROGS) $(CC_PROGS)

create_obj_dir: 
	mkdir -p $(ODIR)

create_bin_dir:
	mkdir -p $(BINDIR)

create_asm_dir:
	mkdir -p $(ASMDIR)

create_results_dir:
	mkdir -p $(RESULTS_DIR)


%.o: $(SRC_DIR)/%.cpp create_obj_dir
	$(CXX) -c -o $(ODIR)/$@ $< $(CFLAGS)

%.o: $(SRC_DIR)/%.c create_obj_dir
	$(CC) -c -o $(ODIR)/$@ $< $(CFLAGS)

%.s: $(SRC_DIR)/%.cpp create_asm_dir
	$(CXX) -o $(ASMDIR)/$@ -S $< $(ASMFLAGS)

%.s: $(SRC_DIR)/%.c create_asm_dir
	$(CC) -o $(ASMDIR)/$@ -S $< $(ASMFLAGS)


%_o3.o: $(SRC_DIR)/%.c create_obj_dir
	$(CC) -O3 -c -o $(ODIR)/$@ $< $(CFLAGS)

%_o3.o: $(SRC_DIR)/%.cpp create_obj_dir
	$(CXX) -O3 -c -o $(ODIR)/$@ $< $(CFLAGS)

%_o3.s: $(SRC_DIR)/%.cpp create_asm_dir
	$(CXX) -O3 -o $(ASMDIR)/$@ -S $< $(ASMFLAGS)

%_o3.s: $(SRC_DIR)/%.c create_asm_dir
	$(CC) -O3 -o $(ASMDIR)/$@ -S $< $(ASMFLAGS)


$(CXX_PROGS): %: %.o %_o3.o %_o3.s  %.s create_bin_dir
	$(CXX) -o $(BINDIR)/$@ $(ODIR)/$@.o $(CFLAGS)
	$(CXX) -o $(BINDIR)/$@_o3 $(ODIR)/$@_o3.o $(CFLAGS)

$(CC_PROGS): %: %.o %_o3.o %_o3.s %.s create_bin_dir
	$(CC) -o $(BINDIR)/$@ $(ODIR)/$@.o $(CFLAGS)
	$(CC) -o $(BINDIR)/$@_o3 $(ODIR)/$@_o3.o $(CFLAGS)


.PHONY: clean build generate_data create_obj_dir create_bin_dir create_asm_dir


generate_data: create_results_dir
	python3 $(SRC_DIR)/gen_data.py $(RESULTS_DIR)/$(DATA_FILE) $(ROWS) $(RANDOM_SEED)

run_experiments: create_results_dir
	python3 $(SRC_DIR)/run_experiments.py $(RESULTS_DIR)/$(RES_CSV_FILE) $(EXP_RANGE_BEGIN) $(EXP_STEP) $(EXP_STEPS_NUMBER) $(EXP_PROBES)

clean:
	rm -f $(ASMDIR)/* $(BINDIR)/* $(RESULTS_DIR)/* $(ODIR)/*.o *~ core $(PROGS) $(DATA_FILE) *.csv
	rmdir $(ODIR) || true
	rmdir $(BINDIR) || true
	rmdir $(ASMDIR) || true
	rmdir $(RESULTS_DIR) || true
