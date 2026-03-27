module pwm_8bit (
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  dutyCycle,
    output wire        pwm_out
);

wire [7:0] counter;
wire [7:0] next_counter;
wire cout_dummy;

wire L, Eq, G;

// --------------------
// 1️⃣ 8-bit Adder (counter + 1)
// --------------------
adder_8bit adder_inst (
    .a(counter),
    .b(8'b00000001),
    .cin(1'b0),
    .sum(next_counter),
    .cout(cout_dummy)
);

// --------------------
// 2️⃣ 8-bit Register (Counter Storage)
// --------------------
dff_8bit counter_reg (
    .q(counter),
    .d(next_counter),
    .clk(clk),
    .rst_n(rst_n)
);

// --------------------
// 3️⃣ Comparator (counter vs dutyCycle)
// --------------------
comparator_8bit comp_inst (
    .A(counter),
    .B(dutyCycle),
    .L(L),
    .Eq(Eq),
    .G(G)
);

// --------------------
// 4️⃣ MUX to Generate PWM
// If counter < dutyCycle → output 1
// --------------------
mux21 pwm_mux (
    .a(1'b0),
    .b(1'b1),
    .s(L),
    .y(pwm_out)
);

endmodule