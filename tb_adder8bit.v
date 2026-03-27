module tb_adder8bit;

    reg [7:0] a, b;
    reg cin;
    wire [7:0] sum;
    wire cout;

    // Instantiate UUT
    adder_8bit uut (
        .a(a), .b(b), .cin(cin), .sum(sum), .cout(cout)
    );

    initial begin
        $dumpfile("dump.vcd"); 
        $dumpvars(0, tb_adder8bit);

        // %0d displays the minimum width decimal (no extra spaces)
        $monitor("Time=%0t | A=%0d + B=%0d + Cin=%0d | Sum=%0d | Cout=%0d", 
                 $time, a, b, cin, sum, cout);

        // Case 1: All zeros
        a = 8'd0;   b = 8'd0;   cin = 1'b0; #10;

        // Case 2: Simple addition
        a = 8'd10;  b = 8'd20;  cin = 1'b0; #10;

        // Case 3: Simple addition with carry-in
        a = 8'd15;  b = 8'd5;   cin = 1'b1; #10;

        // Case 4: Near maximum value (no overflow)
        a = 8'd200; b = 8'd50;  cin = 1'b0; #10;

        // Case 5: Overflow (255 + 1 = 256) -> Sum 0, Cout 1
        a = 8'd255; b = 8'd1;   cin = 1'b0; #10;

        // Case 6: Overflow with Carry-in (255 + 1 + 1) -> Sum 1, Cout 1
        a = 8'd255; b = 8'd1;   cin = 1'b1; #10;

        $finish; 
    end

endmodule 