// ============================================================
// Module  : seg7_display
// Purpose : Displays duty cycle percentage (0–100%) on
//           4-digit 7-segment display with multiplexing
//
// Inputs  : duty [7:0]  — raw duty cycle value (0–255)
// Outputs : seg [6:0]   — segment lines (active LOW, a–g)
//           an  [3:0]   — digit anodes   (active LOW)
//
// Display : "dXXX" where XXX = percentage (e.g. d 062)
//           digit3=d, digit2=hundreds, digit1=tens, digit0=units
//
// Refresh : ~1kHz per digit (4kHz mux rate from 10MHz clock)
// ============================================================

module seg7_display (
    input  wire       clk,       // 10 MHz system clock
    input  wire       rst_n,     // Active-low reset
    input  wire [7:0] duty,      // Raw duty (0–255)
    output reg  [6:0] seg,       // Segments a–g (active LOW)
    output reg  [3:0] an         // Digit anodes  (active LOW)
);

    // ---- Convert duty (0–255) to percentage (0–100) ----
    // percent = duty * 100 / 255  (integer division)
    wire [13:0] percent_full = duty * 14'd100;
    wire [7:0]  percent      = percent_full / 14'd255;  // 0–100

    // ---- Break percentage into 3 decimal digits ----
    wire [3:0] hundreds = percent / 10'd100;
    wire [3:0] tens      = (percent % 10'd100) / 4'd10;
    wire [3:0] units     = percent % 4'd10;

    // ---- Multiplexing counter ----
    // 10MHz / 2500 = 4kHz refresh → each digit at 1kHz
    reg [11:0] mux_count;
    reg [1:0]  digit_sel;   // 0=units, 1=tens, 2=hundreds, 3='d' label

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mux_count <= 0;
            digit_sel <= 0;
        end else begin
            if (mux_count == 12'd2499) begin
                mux_count <= 0;
                digit_sel <= digit_sel + 1;
            end else begin
                mux_count <= mux_count + 1;
            end
        end
    end

    // ---- 7-segment encoder (active LOW segments) ----
    // Segment map:  gfedcba
    //   0 → 1000000, 1 → 1111001, 2 → 0100100 ...
    function [6:0] encode_seg;
        input [3:0] digit;
        case (digit)
            4'd0:    encode_seg = 7'b1000000; // 0
            4'd1:    encode_seg = 7'b1111001; // 1
            4'd2:    encode_seg = 7'b0100100; // 2
            4'd3:    encode_seg = 7'b0110000; // 3
            4'd4:    encode_seg = 7'b0011001; // 4
            4'd5:    encode_seg = 7'b0010010; // 5
            4'd6:    encode_seg = 7'b0000010; // 6
            4'd7:    encode_seg = 7'b1111000; // 7
            4'd8:    encode_seg = 7'b0000000; // 8
            4'd9:    encode_seg = 7'b0010000; // 9
            default: encode_seg = 7'b1111111; // blank
        endcase
    endfunction

    // ---- Select active digit and segment pattern ----
    always @(*) begin
        case (digit_sel)
            2'd0: begin
                an  = 4'b1110;               // Rightmost digit (units)
                seg = encode_seg(units);
            end
            2'd1: begin
                an  = 4'b1101;               // Tens
                seg = encode_seg(tens);
            end
            2'd2: begin
                an  = 4'b1011;               // Hundreds
                seg = encode_seg(hundreds);
            end
            2'd3: begin
                an  = 4'b0111;               // Leftmost digit: show 'd'
                seg = 7'b0100001;            // 'd' pattern
            end
            default: begin
                an  = 4'b1111;
                seg = 7'b1111111;
            end
        endcase
    end

endmodule
