DATA_FILE=data.txt
ROWS=100000
RANDOM_SEED=7

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

CXX_PROGS = valarray 
CC_PROGS = gcc_vector normal


all: build generate_data

build: $(CXX_PROGS) $(CC_PROGS)

create_obj_dir: 
	mkdir -p $(ODIR)

create_bin_dir:
	mkdir -p $(BINDIR)

create_asm_dir:
	mkdir -p $(ASMDIR)

%.o: $(SRC_DIR)/%.cpp create_obj_dir
	$(CXX) -c -o $(ODIR)/$@ $< $(CFLAGS)

%.o: $(SRC_DIR)/%.c create_obj_dir
	$(CC) -c -o $(ODIR)/$@ $< $(CFLAGS)

%_o3.o: $(SRC_DIR)/%.c create_obj_dir
	$(CC) -O3 -c -o $(ODIR)/$@ $< $(CFLAGS)

%.s: $(SRC_DIR)/%.cpp create_asm_dir
	$(CXX) -o $(ASMDIR)/$@ -S $< $(ASMFLAGS)

%.s: $(SRC_DIR)/%.c create_asm_dir
	$(CC) -o $(ASMDIR)/$@ -S $< $(ASMFLAGS)

%_o3.s: $(SRC_DIR)/%.c create_asm_dir
	$(CC) -O3 -o $(ASMDIR)/$@ -S $< $(ASMFLAGS)

$(CXX_PROGS): %: %.o %.s create_bin_dir
	$(CXX) -o $(BINDIR)/$@ $(ODIR)/$@.o $(CFLAGS)

$(CC_PROGS): %: %.o %_o3.o %_o3.s %.s create_bin_dir
	$(CC) -o $(BINDIR)/$@ $(ODIR)/$@.o $(CFLAGS)
	$(CC) -o $(BINDIR)/$@_o3 $(ODIR)/$@_o3.o $(CFLAGS)


.PHONY: clean build generate_data create_obj_dir create_bin_dir create_asm_dir


generate_data:
	python3 $(SRC_DIR)/gen_data.py $(DATA_FILE) $(ROWS) $(RANDOM_SEED)


clean:
	rm -f $(ASMDIR)/* $(BINDIR)/* $(ODIR)/*.o *~ core $(PROGS) $(DATA_FILE)
	rmdir $(ODIR) || true
	rmdir $(BINDIR) || true
	rmdir $(ASMDIR) || true
