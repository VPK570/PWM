# AGENTS.md — PWM Generator (Structural Verilog)

## Project Overview
8-bit counter-based PWM generator with UART control, 7-segment display, and prescaler. Built using structural Verilog HDL targeting FPGA deployment. System clock: 10 MHz.

## Commands

### Run All Tests
```bash
bash run_all.sh
```

### Run a Single Module Test
Compile and simulate one module at a time — **never** use `iverilog *.v` (causes module name collisions across testbenches).

```bash
# Pattern: iverilog -o sim_<name>.vvp <design>.v <testbench>.v && vvp sim_<name>.vvp

# Submodules
iverilog -o sim_adder.vvp adder_8bit.v tb_adder8bit.v && vvp sim_adder.vvp
iverilog -o sim_mux.vvp mux21.v tb_mux21.v && vvp sim_mux.vvp
iverilog -o sim_dff.vvp dff_8bit.v tb_dff_8bit.v && vvp sim_dff.vvp
iverilog -o sim_comp.vvp comparator_8bit.v tb_comparator_8bit.v && vvp sim_comp.vvp

# Extended modules
iverilog -o sim_prescaler.vvp prescaler.v tb_prescaler.v && vvp sim_prescaler.vvp
iverilog -o sim_uart.vvp uart_rx.v tb_uart_rx.v && vvp sim_uart.vvp
iverilog -o sim_seg7.vvp seg7_display.v tb_seg7.v && vvp sim_seg7.vvp

# Full PWM core (needs all submodules)
iverilog -o sim_pwm.vvp adder_8bit.v dff_8bit.v mux21.v comparator_8bit.v pwm.v tb_pwm.v && vvp sim_pwm.vvp
```

### View Waveforms
```bash
gtkwave dump.vcd               # PWM core
gtkwave dump_prescaler.vcd     # Prescaler
gtkwave dump_uart.vcd          # UART RX
gtkwave dump_seg7.vcd          # 7-Segment display
```

### Clean Simulation Artifacts
```bash
rm -f sim_*.vvp dump*.vcd
```

## Code Style

### File Organization
- One module per file for leaf modules (e.g. `mux21.v`, `dff_1bit`)
- Parent + child modules can share a file (e.g. `dff_8bit.v` contains both `dff_1bit` and `dff_8bit`)
- Testbenches prefixed with `tb_` (e.g. `tb_pwm.v`)
- Top-level integration in `top.v`

### Module Declaration
- Use Verilog-2001 ANSI-style port declarations
- Ports ordered: inputs first, then outputs
- Use explicit `wire`/`reg` types — never rely on implicit declarations
- Named port instantiation (`.port_name(signal)`) — never positional

```verilog
module module_name #(
    parameter PARAM_NAME = default_value
)(
    input  wire       clk,
    input  wire       rst_n,
    input  wire [7:0] data_in,
    output reg  [7:0] data_out
);
```

### Naming Conventions
- **Modules**: `snake_case` (e.g. `adder_8bit`, `comparator_1bit`)
- **Signals**: `snake_case` (e.g. `duty_cycle`, `slow_clk`)
- **Active-low signals**: suffix `_n` (e.g. `rst_n`)
- **Testbench modules**: `tb_<module_name>` (e.g. `tb_pwm`)
- **Instance names**: `<module_type>_<suffix>` (e.g. `adder_inst`, `pwm_mux`)
- **Parameters**: `UPPER_CASE` (e.g. `DIVISOR`, `CLKS_PER_BIT`)
- **Localparams** (FSM states): `UPPER_CASE` (e.g. `IDLE`, `START`, `RECEIVE`)

### Timescale
- Always include `` `timescale 1ns/1ps `` at the top of testbench files
- Design files (non-testbench) should NOT include `timescale`

### Reset Convention
- Active-low asynchronous reset (`rst_n`)
- Always include `negedge rst_n` in sensitivity list for sequential blocks
- Default reset values: registers → 0, duty registers → 8'd128 (50%)

```verilog
always @(posedge clk or negedge rst_n) begin
    if (!rst_n)
        reg_signal <= default_value;
    else
        reg_signal <= next_value;
end
```

### Combinational vs Sequential
- **Combinational**: use `assign` for simple logic, `always @(*)` for complex
- **Sequential**: use `always @(posedge clk or negedge rst_n)` with non-blocking `<=`
- Inside `always @(*)` blocks, use blocking `=` assignments

### FSM Style
- Use `localparam` for state encoding
- Single `always` block with `case(state)` pattern
- Include `default: state <= IDLE;` for safety

### Testbench Conventions
- Always include `$dumpfile("dump.vcd")` and `$dumpvars(0, tb_name)`
- Use `$display` and `$monitor` for console output
- Name the DUT instance `uut`
- Test edge cases: overflow, reset behavior, boundary values

### Comments
- Use `//` for inline comments
- Use `// ---- Section Name ----` dividers for module sections
- Top-level modules get a header block with purpose and pin descriptions
- Avoid emoji in production code (testbench comments may use them)

### Generate Blocks
- Use `generate`/`endgenerate` with named blocks for replicated logic
- Label genvar loops: `for (i = 0; i < 8; i = i + 1) begin : gen_label`

## Architecture Notes
- **Prescaler**: Parameterized clock divider. `DIVISOR=4` for DC motor (~10 kHz PWM), `DIVISOR=781` for servo (50 Hz)
- **UART RX**: 9600 baud, 8N1, 3-digit ASCII to 8-bit duty cycle conversion
- **7-Segment**: Multiplexed 4-digit display showing "dXXX" (duty percentage)
- **PWM Core**: Counter (0–255) + comparator + MUX — structural design only
- **Never compile all .v files together** — each testbench must be compiled with only its required design files
