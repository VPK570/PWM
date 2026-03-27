`timescale 1ns/1ps

module dff_8bit_tb;

reg  [7:0] d;
reg  clk;
reg  rst_n;
wire [7:0] q;

// Instantiate DUT
dff_8bit uut (
    .q(q),
    .d(d),
    .clk(clk),
    .rst_n(rst_n)
);

// Clock generation (10ns period)
always #5 clk = ~clk;

initial begin
    $dumpfile("dump_dff_8bit.vcd");
    $dumpvars(0, dff_8bit_tb);

    $display("Starting 8-bit DFF Testbench");
    $display("--------------------------------");

    clk = 0;
    rst_n = 0;
    d = 8'b00000000;

    // Apply reset
    #12;
    rst_n = 1;   // Release reset

    // Apply test vectors
    #10 d = 8'b10101010;
    #10 check_output();

    #10 d = 8'b11110000;
    #10 check_output();

    #10 d = 8'b00001111;
    #10 check_output();

    #10 d = 8'b11111111;
    #10 check_output();

    #10 d = 8'b00000000;
    #10 check_output();

    $display("--------------------------------");
    $display("Testing Completed");
    $finish;
end


// Task to verify output
task check_output;
begin
    if (q === d)
        $display("PASS  Time=%0t  D=%b  Q=%b", $time, d, q);
    else
        $display("FAIL  Time=%0t  D=%b  Q=%b", $time, d, q);
end
endtask

endmodule