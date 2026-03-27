// Testbench for 2:1 MUX
module tb_mux21;
    reg a, b, s;
    wire y;

    // Instantiate the Unit Under Test (UUT)
    mux21 uut (
        .a(a), .b(b), .s(s), .y(y)
    );

    initial begin
        // Monitor changes
        $dumpfile("dump.vcd"); // Dump waveforms to a VCD file for viewing
        $dumpvars(0, tb_mux21); // Dump all variables in the test bench
        $monitor("At time %t: s=%b, a=%b, b=%b, y=%b", $time, s, a, b, y);

        // Apply test vectors
        s=0; a=0; b=1; #10;
        s=0; a=1; b=0; #10;
        s=1; a=0; b=0; #10;
        s=1; a=0; b=1; #10;
        
        $finish;
    end
endmodule
