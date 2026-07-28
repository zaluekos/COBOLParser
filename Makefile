COBC = cobc
COBCFLAGS = -x -free
GEN = dotnet
GENPROJ = GenProgram.csproj

COB_SRC = parser.cob
COB_EXE = parser

CS_SRC = GenProgram.cs
CS_EXE = GenProgram.dll

DATA_DIR = data
INPUT_FILE = $(DATA_DIR)/customers_input.dat
OUTPUT_FILE = $(DATA_DIR)/customers_output.csv
COBCFLAGS = -x -free -I cpy

.PHONY: all cobol csharp run clean prep

all: cobol csharp

prep:
	mkdir -p $(DATA_DIR)

cobol: prep $(COB_SRC)
	$(COBC) $(COBCFLAGS) -o $(COB_EXE) $(COB_SRC)

csharp: prep $(GENPROJ) $(CS_SRC)
	$(GEN) build $(GENPROJ) -c Release

run: all
	./$(COB_EXE)

clean:
	rm -f $(COB_EXE)
	rm -f $(OUTPUT_FILE)
	rm -rf bin obj