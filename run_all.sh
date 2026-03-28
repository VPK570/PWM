#!/bin/bash
echo "===== Adder =====" && iverilog -o sim_adder.vvp adder_8bit.v tb_adder8bit.v && vvp sim_adder.vvp
echo "===== MUX =====" && iverilog -o sim_mux.vvp mux21.v tb_mux21.v && vvp sim_mux.vvp
echo "===== DFF =====" && iverilog -o sim_dff.vvp dff_8bit.v tb_dff_8bit.v && vvp sim_dff.vvp
echo "===== Comparator =====" && iverilog -o sim_comp.vvp comparator_8bit.v tb_comparator_8bit.v && vvp sim_comp.vvp
echo "===== Prescaler =====" && iverilog -o sim_prescaler.vvp prescaler.v tb_prescaler.v && vvp sim_prescaler.vvp
echo "===== UART RX =====" && iverilog -o sim_uart.vvp uart_rx.v tb_uart_rx.v && vvp sim_uart.vvp
echo "===== 7-Segment =====" && iverilog -o sim_seg7.vvp seg7_display.v tb_seg7.v && vvp sim_seg7.vvp
echo "===== Full PWM =====" && iverilog -o sim_pwm.vvp adder_8bit.v dff_8bit.v mux21.v comparator_8bit.v pwm.v tb_pwm.v && vvp sim_pwm.vvp
echo "===== ALL DONE ====="
