`timescale 1ns/1ps

module tb_pwm;

reg clk;
reg rst_n;
reg [7:0] dutyCycle;
wire pwm_out;

// Instantiate DUT
pwm_8bit uut (
    .clk(clk),
    .rst_n(rst_n),
    .dutyCycle(dutyCycle),
    .pwm_out(pwm_out)
);

// Clock generation (10ns period → 100MHz)
always #5 clk = ~clk;

initial begin
    $display("Starting PWM Testbench...");

    $dumpfile("dump.vcd"); // Dump waveforms to a VCD file for viewing
    $dumpvars(0, tb_pwm);
    
    clk = 0;
    rst_n = 0;
    dutyCycle = 8'd0;

    // Apply reset
    #20;
    rst_n = 1;

    // 25% duty cycle
    dutyCycle = 8'd64;     // 64/256 = 25%
    #9000;



    $display("Simulation Finished.");
    $finish;
end

// Optional monitor
initial begin
    $monitor("Time=%0t | Duty=%d | PWM=%b", 
              $time, dutyCycle, pwm_out);
end

endmodule