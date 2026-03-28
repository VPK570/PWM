Here's the exact sequence of commands to run everything — copy paste them one by one:

### Adder

```bash
iverilog -o sim_adder.vvp adder_8bit.v tb_adder8bit.v
vvp sim_adder.vvp
```

### MUX

```bash
iverilog -o sim_mux.vvp mux21.v tb_mux21.v
vvp sim_mux.vvp
```

### DFF

```bash
iverilog -o sim_dff.vvp dff_8bit.v tb_dff_8bit.v
vvp sim_dff.vvp
```

### Comparator

```bash
iverilog -o sim_comp.vvp comparator_8bit.v tb_comparator_8bit.v
vvp sim_comp.vvp
```

### Prescaler

```bash
iverilog -o sim_prescaler.vvp prescaler.v tb_prescaler.v
vvp sim_prescaler.vvp
```

### UART RX

```bash
iverilog -o sim_uart.vvp uart_rx.v tb_uart_rx.v
vvp sim_uart.vvp
```

### 7-Segment Display

```bash
iverilog -o sim_seg7.vvp seg7_display.v tb_seg7.v
vvp sim_seg7.vvp
```

### Full PWM core

```bash
iverilog -o sim_pwm.vvp adder_8bit.v dff_8bit.v mux21.v comparator_8bit.v pwm.v tb_pwm.v
vvp sim_pwm.vvp
```

```bash
# Open each waveform
gtkwave dump_prescaler.vcd
gtkwave dump_uart.vcd
gtkwave dump_seg7.vcd
gtkwave dump.vcd               # for PWM core
```
