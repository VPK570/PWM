`timescale 1ns/1ps
module tb_seg7;

reg        clk, rst_n;
reg  [7:0] duty;
wire [6:0] seg;
wire [3:0] an;

seg7_display uut (
    .clk(clk), .rst_n(rst_n),
    .duty(duty), .seg(seg), .an(an)
);

always #50 clk = ~clk;

// Decode seg back to digit for display verification
function [3:0] decode_seg;
    input [6:0] s;
    case (s)
        7'b1000000: decode_seg = 0;
        7'b1111001: decode_seg = 1;
        7'b0100100: decode_seg = 2;
        7'b0110000: decode_seg = 3;
        7'b0011001: decode_seg = 4;
        7'b0010010: decode_seg = 5;
        7'b0000010: decode_seg = 6;
        7'b1111000: decode_seg = 7;
        7'b0000000: decode_seg = 8;
        7'b0010000: decode_seg = 9;
        default:    decode_seg = 15; // unknown
    endcase
endfunction

task check_display;
    input [7:0] d;
    input [7:0] expected_pct;
    integer i;
    reg [3:0] digits_seen [0:2];
    reg [1:0] di;
    begin
        duty = d;
        #1000000; // Wait for a few mux cycles
        $display("duty=%0d → expected %0d%% | seg=%b an=%b",
                  d, expected_pct, seg, an);
    end
endtask

initial begin
    $dumpfile("dump_seg7.vcd");
    $dumpvars(0, tb_seg7);
    clk = 0; rst_n = 0; duty = 0;
    #500; rst_n = 1;

    $display("--- 7-Segment Display Tests ---");
    check_display(8'd64,  25);   // 25%
    check_display(8'd128, 50);   // 50%
    check_display(8'd192, 75);   // 75%
    check_display(8'd255, 100);  // 100%
    check_display(8'd0,   0);    // 0%

    $display("Done."); $finish;
end
endmodule
