# Logic Networks Project — Politecnico di Milano

Final project for the **Logic Networks** course (Politecnico di Milano), by **Giuseppe D'Ambrosi** and **Loreto Del Vecchio**.

## Description

The project consists of describing and synthesizing in VHDL a hardware component that interfaces with an external memory: it reads a header and a data sequence from memory, applies a **differential filter** to the data (3rd or 5th order, selected by the header), and writes the filtered sequence back to memory right after the input.

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

All signals are synchronous to the clock, except for reset, which is asynchronous. `i_start` is raised (and held) by the testbench to launch a computation and `o_done` is raised once the result has been written back to memory; the memory itself is instantiated by the testbench and is not part of the synthesized design. The official assignment is described in [`specification/project_specification.pdf`](./specification/project_specification.pdf) and [`specification/submission_rules.pdf`](./specification/submission_rules.pdf); design choices and simulation results are described in [`project_report.pdf`](./project_report.pdf).

### Memory layout

Starting at `i_add`, the module expects a 17-byte header followed by the `K`-byte input sequence `W`, and writes the `K`-byte filtered output `R` right after it:

| Bytes | Field | Meaning |
|---|---|---|
| `ADD` .. `ADD+1` | `K1`, `K2` | Sequence length `K` (big-endian, `K1` most significant), minimum 7 |
| `ADD+2` | `S` | Filter select: LSB `0` → order 3, LSB `1` → order 5 |
| `ADD+3` .. `ADD+16` | `C1` .. `C14` | 7 coefficients for the order-3 filter, then 7 for the order-5 filter |
| `ADD+17` .. `ADD+17+K-1` | `W` | Input sequence, signed bytes (-128..127, two's complement) |
| `ADD+17+K` .. `ADD+17+2K-1` | `R` | Filtered output sequence, written by the module |

For each output sample `f'(i) = (1/n) * Σ Cⱼ · f[j+i]`, with `j` in `[-l, l]` and samples outside the sequence treated as `0`:

| Filter | Coefficients `C` | Normalization `n` | Window `l` |
|---|---|---|---|
| Order 3 | `[0, -1, 8, 0, -8, 1, 0]` | 12 | 2 |
| Order 5 | `[1, -9, 45, 0, -45, 9, -1]` | 60 | 3 |

Since `n` is not a power of two, the division is approximated with right shifts (`1/12 ≈ 1/16 + 1/64 + 1/256 + 1/1024`, `1/60 ≈ 1/64 + 1/1024`), each corrected by `+1` when the shifted value is negative to compensate for the truncation of arithmetic shifts; the final result is saturated to `[-128, 127]`.

## Architecture

The top-level component (`project_reti_logiche`, in [`src/project.vhd`](./src/project.vhd)) instantiates and orchestrates the following modules:

- **FSM** — a 7-state controller (`S0`..`S6`) that sequences the whole computation: waiting for `i_start`, reading the 17-byte header, streaming the input sequence into the buffer, priming the filter pipeline, writing the filtered output back to memory, and finally raising `o_done`. It drives the memory bus and enables the other modules in the correct phase.
- **COUNTER** — a shared 24-bit position counter, reset by the FSM at each phase, used to generate memory addresses and to detect the end of each phase.
- **SHIFT_REG** — a 136-bit shift register that captures the header byte by byte and exposes the sequence length (`K1`/`K2`), the filter selector (`S`) and the 14 packed coefficient bytes.
- **buf** — stores the full `K`-byte input sequence as it streams in and continuously outputs the 7-sample sliding window centered on the current position, zero-padding samples outside `[0, K)`.
- **DIFFERENTIAL_FILTER** — multiplies the windowed samples by the coefficients selected by `S`, sums them, applies the shift-based normalization described above, saturates the result, and hands the filtered byte back to the FSM to be written to memory.

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
