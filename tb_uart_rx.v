`timescale 1ns/1ps

module tb_uart_rx;

reg        clk, rst_n;
reg        rx;
wire [7:0] duty_out;
wire       duty_valid;

uart_rx uut (
    .clk(clk), .rst_n(rst_n),
    .rx(rx),
    .duty_out(duty_out),
    .duty_valid(duty_valid)
);

// 10 MHz clock
always #50 clk = ~clk;

// Baud rate: 9600 → bit period = 1042 * 100ns = 104,200ns
localparam BIT_PERIOD = 104200; // ns

// Task: send one UART byte (8N1, LSB first)
task send_byte;
    input [7:0] data;
    integer i;
    begin
        // Start bit
        rx = 1'b0;
        #BIT_PERIOD;
        // 8 data bits LSB first
        for (i = 0; i < 8; i = i + 1) begin
            rx = data[i];
            #BIT_PERIOD;
        end
        // Stop bit
        rx = 1'b1;
        #BIT_PERIOD;
    end
endtask

// Task: send string "XYZ\n"
task send_duty_string;
    input [7:0] d2, d1, d0; // hundreds, tens, units
    begin
        send_byte(8'h30 + d2); // ASCII digit
        send_byte(8'h30 + d1);
        send_byte(8'h30 + d0);
        send_byte(8'h0A);      // newline
    end
endtask

initial begin
    $dumpfile("dump_uart.vcd");
    $dumpvars(0, tb_uart_rx);

    clk   = 0;
    rst_n = 0;
    rx    = 1'b1;   // UART idle = HIGH
    #500;
    rst_n = 1;
    #500;

    $display("--- Test 1: Send '064' → duty = 64 (25%%) ---");
    send_duty_string(0, 6, 4);
    #5000;
    if (duty_valid)
        $display("PASS  duty_out = %d (expected 64)", duty_out);

    $display("--- Test 2: Send '128' → duty = 128 (50%%) ---");
    send_duty_string(1, 2, 8);
    #5000;
    if (duty_valid)
        $display("PASS  duty_out = %d (expected 128)", duty_out);

    $display("--- Test 3: Send '255' → duty = 255 (100%%) ---");
    send_duty_string(2, 5, 5);
    #5000;
    if (duty_valid)
        $display("PASS  duty_out = %d (expected 255)", duty_out);

    $display("--- Test 4: Send '000' → duty = 0 (0%%) ---");
    send_duty_string(0, 0, 0);
    #5000;
    if (duty_valid)
        $display("PASS  duty_out = %d (expected 0)", duty_out);

    $display("Simulation Complete.");
    $finish;
end

// Print whenever a new valid duty arrives
always @(posedge clk) begin
    if (duty_valid)
        $display("  >> duty_valid! duty_out = %0d", duty_out);
end

endmodule
