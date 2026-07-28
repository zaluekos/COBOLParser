# Fixed-Width COBOL Parser & C# Test Data Generator

A small enterprise-style data pipeline for generating fixed-width mainframe input in C# and parsing it in COBOL for validation and CSV export.
The repository demonstrates how legacy-style fixed-width records, packed decimals (COMP-3), and COBOL copybooks can be combined with a modern test-data generator to create a batch-processing workflow.
## What This Project Shows

- Fixed-width record generation from C# into binary mainframe-style input.
- COBOL parsing of raw records into normalized working-storage structures.
- Validation of business rules such as status codes, blank identifiers, and date ranges.
- CSV export from COBOL using explicit formatting and string construction.
- Separation of concerns between raw input, reusable copybooks, and normalized DTO-style working data.
- COBOL table handling and memory structures, including OCCURS, REDEFINES, indexed access, and working-storage patterns for batch-oriented data processing.

## Repository Layout

```text
.
├── GenProgram.cs         # C# generator for customers_input.dat
├── parser.cob            # COBOL batch parser and CSV exporter
├── Makefile              # Build and run helpers
├── cpy/                  # Reusable COBOL copybooks
├── data/                 # Generated inputs and outputs
│   ├── customers_input.dat
│   └── customers_output.csv
└── README.md
```

## Conceptual Design

This project is built around a simple but realistic batch-processing pattern:

1. The C# generator creates a fixed-width binary test file.
2. The COBOL program reads the raw record bytes.
3. The raw record is moved into working-storage fields for validation and normalization.
4. Valid records are written to CSV.
5. Invalid records are reported through status messages.

The code intentionally separates raw file layout from normalized working data so that the parser logic remains easier to maintain and extend.

## Data Format

The input file is a fixed-width record file with fields such as:

- Customer ID.
- First name.
- Last name.
- Join date.
- Account status.
- Balance stored as packed decimal (COMP-3).

The output file is a CSV export created by COBOL after validation.

## COBOL Techniques Used

- `REDEFINES` for alternate views of the same storage.
- `STRING` for assembling CSV output.
- Fixed-width record definitions for raw file parsing.
- Packed decimal handling for COMP-3 numeric fields.
- Working-storage separation for raw, normalized, and output data.

## Requirements

To build and run this project, you need:

- A COBOL compiler such as GnuCOBOL.
- .NET SDK for the C# generator.
- A shell environment that can run `make`.

## How to Build

```bash
make all
```

This builds the COBOL parser and the C# generator.

If you want to build only one side:

```bash
make cobol
make csharp
```

## How to Run

1. Generate the input file with the C# program.
2. Run the COBOL parser.
3. Inspect `data/customers_output.csv`.

If your Makefile is set up to run the full pipeline, a single command may be enough:

```bash
make run
```

## Expected Output

The parser reads `data/customers_input.dat`, validates each record, and writes a CSV file to `data/customers_output.csv`.

Invalid records are rejected with messages such as:

- `ERR-NO-ID`
- `ERR-BAD-STAT`
- `ERR-BAD-DATE`

## Why This Structure

This layout is meant to mirror real-world enterprise batch systems:

- A generator creates test data.
- A COBOL job consumes it.
- Copybooks define the shared contract.
- Output is normalized for downstream systems.

That makes the repository useful both as a practical utility and as a study of legacy-modern integration.

## Notes

- The `cpy/` folder is intended for reusable copybooks shared across COBOL programs.
- The `data/` folder stores generated inputs and outputs only.
- The project is designed to be easy to extend with JSON export, additional validations, or more record types.