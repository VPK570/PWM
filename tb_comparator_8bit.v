`timescale 1ns/1ps

module tb_comparator_8bit;

reg  [7:0] A, B;
wire L, Eq, G;

// Instantiate the DUT
comparator_8bit uut (
    .A(A),
    .B(B),
    .L(L),
    .Eq(Eq),
    .G(G)
);

// Expected outputs
reg exp_L, exp_Eq, exp_G;

// Test counter
integer i;

initial begin
    $dumpfile("dump.vcd"); // Dump waveforms to a VCD file for viewing
    $dumpvars(0, tb_comparator_8bit); // Dump all variables in the test bench

    $display("Starting 8-bit Comparator Test...");
    $display("-----------------------------------");

    // -------- Directed Test Cases --------
    
    A = 8'd0; B = 8'd0; #10 check_result();
    A = 8'd10; B = 8'd5; #10 check_result();
    A = 8'd5; B = 8'd10; #10 check_result();
    A = 8'd255; B = 8'd255; #10 check_result();
    A = 8'd128; B = 8'd127; #10 check_result();
    A = 8'd127; B = 8'd128; #10 check_result();
    
    // -------- Random Test Cases --------
    
    for (i = 0; i < 50; i = i + 1) begin
        A = $random;
        B = $random;
        #10 check_result();
    end

    $display("-----------------------------------");
    $display("Testing Completed.");
    $finish;
end


// Task to verify results
task check_result;
begin

    // Compute expected values
    exp_G  = (A > B);
    exp_L  = (A < B);
    exp_Eq = (A == B);

    if ((G === exp_G) && (L === exp_L) && (Eq === exp_Eq))
        $display("PASS  A=%d  B=%d  | G=%b L=%b Eq=%b", A, B, G, L, Eq);
    else
        $display("FAIL  A=%d  B=%d  | G=%b L=%b Eq=%b  | Expected G=%b L=%b Eq=%b",
                 A, B, G, L, Eq, exp_G, exp_L, exp_Eq);

end
endtask

endmodule