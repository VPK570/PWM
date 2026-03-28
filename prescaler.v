// ============================================================
// Module  : prescaler
// Purpose : Divides input clock by DIVISOR to produce slow_clk
//
// How to use:
//   DC Motor  (≈10 kHz PWM) → DIVISOR = 4   (10MHz/4 = 2.5MHz → /256 = 9.77kHz)
//   Servo     (50 Hz  PWM)  → DIVISOR = 781 (10MHz/781 = 12.8kHz → /256 = 50Hz)
//
// Default is DIVISOR=4 (DC motor). Change at instantiation.
// ============================================================

module prescaler #(
    parameter DIVISOR = 4       // Change this for target frequency
)(
    input  wire clk,            // System clock (10 MHz)
    input  wire rst_n,          // Active-low reset
    output reg  slow_clk        // Divided clock output
);

    // Counter needs to count up to DIVISOR/2 to toggle slow_clk
    // Width = ceil(log2(DIVISOR/2)) — 16 bits is safe for DIVISOR up to 65535
    reg [15:0] count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count    <= 16'd0;
            slow_clk <= 1'b0;
        end else begin
            if (count == (DIVISOR/2 - 1)) begin
                slow_clk <= ~slow_clk;  // Toggle → produces divided clock
                count    <= 16'd0;
            end else begin
                count <= count + 1'b1;
            end
        end
    end

endmodule
