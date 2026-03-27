// ============================================================
// Module  : top
// Purpose : Top-level integration of PWM system
//
// Connections:
//   clk      ← FPGA oscillator (10 MHz)
//   rst_n    ← Push button (active low)
//   uart_rxd ← USB-UART RX pin
//   pwm_out  → Motor / Servo output pin
//   seg[6:0] → 7-segment cathodes
//   an[3:0]  → 7-segment anodes
// ============================================================

module top (
    input  wire       clk,        // 10 MHz FPGA clock
    input  wire       rst_n,      // Active-low reset button
    input  wire       uart_rxd,   // UART RX from PC
    output wire       pwm_out,    // PWM output to motor/servo
    output wire [6:0] seg,        // 7-segment segments
    output wire [3:0] an          // 7-segment anodes
);

    wire [7:0] duty;          // Duty cycle from UART
    wire       duty_valid;    // New duty received flag
    wire       slow_clk;      // Prescaled clock for PWM counter
    reg  [7:0] duty_reg;      // Registered duty cycle (holds last valid)

    // ---- 1. Prescaler ----
    // DIVISOR=4  → 2.5 MHz → PWM ≈ 9.77 kHz  (DC motor)
    // DIVISOR=781→ 12.8kHz → PWM ≈ 50 Hz      (Servo — change when needed)
    prescaler #(.DIVISOR(4)) prescaler_inst (
        .clk(clk),
        .rst_n(rst_n),
        .slow_clk(slow_clk)
    );

    // ---- 2. UART Receiver ----
    uart_rx uart_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx(uart_rxd),
        .duty_out(duty),
        .duty_valid(duty_valid)
    );

    // ---- 3. Duty cycle register (latch on valid) ----
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            duty_reg <= 8'd128;   // Default 50% on reset
        else if (duty_valid)
            duty_reg <= duty;
    end

    // ---- 4. PWM Generator ----
    pwm_8bit pwm_inst (
        .clk(slow_clk),
        .rst_n(rst_n),
        .dutyCycle(duty_reg),
        .pwm_out(pwm_out)
    );

    // ---- 5. 7-Segment Display ----
    seg7_display seg7_inst (
        .clk(clk),
        .rst_n(rst_n),
        .duty(duty_reg),
        .seg(seg),
        .an(an)
    );

endmodule
