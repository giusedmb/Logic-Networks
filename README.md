# Logic Networks Project — Politecnico di Milano

Final project for the **Logic Networks** course (Politecnico di Milano), by **Giuseppe D'Ambrosi** and **Loreto Del Vecchio**.

## Description

The project consists of describing and synthesizing in VHDL a hardware component that interfaces with an external memory: it reads a block of commands and a data sequence from memory, applies a **differential filter** to the data (either 3rd or 5th order, selectable, based on the coefficients provided in the commands), and writes the results back to memory.

The top-level entity is the following:

```vhdl
entity project_reti_logiche is
    port(
        i_clk: in std_logic;
        i_rst: in std_logic;
        i_start: in std_logic;
        i_add: in std_logic_vector(15 downto 0);

        o_done: out std_logic;

        o_mem_addr: out std_logic_vector(15 downto 0);
        i_mem_data: in std_logic_vector(7 downto 0);
        o_mem_data: out std_logic_vector(7 downto 0);
        o_mem_we: out std_logic;
        o_mem_en: out std_logic
    );
end entity;
```

All signals are synchronous to the clock, except for reset. The official assignment is described in [`specification/project_specification.pdf`](./specification/project_specification.pdf) and [`specification/submission_rules.pdf`](./specification/submission_rules.pdf); design choices and simulation results are described in [`project_report.pdf`](./project_report.pdf).

## Architecture

The top-level component (`project_reti_logiche`, in [`src/project.vhd`](./src/project.vhd)) instantiates and orchestrates the following modules:

- **FSM** — operations director: manages the handshake with memory and enables the other components in the correct phases.
- **SHIFT_REG** — reads and stores the initial commands (sequence length, filter type, coefficients).
- **COUNTER** — keeps count of the processed elements.
- **buf** — holds the last 7 samples needed for the filter computation in a sliding-window register.
- **DIFFERENTIAL_FILTER** — applies the linear combination of samples with the coefficients and normalizes the result.

## Repository structure

```
src/
└── project.vhd                           → final, complete source code (all modules)

specification/
├── project_specification.pdf             → official project specification
└── submission_rules.pdf                  → official submission rules

project_report.pdf                        → final project report

vhdl_project/                             → development history and auxiliary material
├── 0_.../1_.../2_.../4_.../5_.../6_...    → progressive development snapshots of the project
│                                            (each with the .vhd sources for fsm, counter,
│                                             differential_filter, shift_register, buffer and project)
├── testbenches/
│   ├── provided_by_professor/            → sample testbench provided by the professor
│   └── custom/                           → testbenches written to validate edge cases
│       (minimum/maximum number of data points, extreme values, random coefficients,
│        multiple start/reset, etc.)
├── vhdl_reference/                       → reference teaching material on VHDL
├── project_specification_2024_25.xlsx    → project specification provided by the professor
├── fsm_state_diagram.pages               → FSM state diagram
└── vector_formatting_helper.txt          → helper script for formatting test vectors
```

`src/project.vhd` is the actual submitted code — the definitive, graded deliverable. Everything under `vhdl_project/` is auxiliary: development snapshots, testbenches and reference material kept for context. The numbered folders (`0` → `6`) are the development steps kept as historical reference: each step adds or fixes a feature (e.g. latch handling, saturation, avoiding memory overwrites, multiple starts, handling of maximum/minimum values).

## Toolchain

Project developed and synthesized with **Xilinx ISE / ISim** (environment required by the course), **VHDL** language.
