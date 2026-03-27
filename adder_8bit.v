module half_adder (
    input a, b,
    output sum, carry
);
    assign sum = a ^ b;
    assign carry = a & b;
endmodule

module full_adder (
    input a, b, cin,
    output sum, cout 
);
    wire s1, c1, c2;

    half_adder ha1(.a(a), .b(b), .sum(s1), .carry(c1));
    half_adder ha2(.a(s1), .b(cin), .sum(sum), .carry(c2));

    assign cout = c1 | c2;
endmodule

module adder_8bit (
    input [7:0] a, b,
    input cin,
    output [7:0] sum,
    output cout
);
    wire [8:0] c;
    assign c[0] = cin;
    assign cout = c[8];

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : gen_adders
            full_adder fa (
                .a(a[i]), 
                .b(b[i]), 
                .cin(c[i]), 
                .sum(sum[i]), 
                .cout(c[i+1])
            );
        end
    endgenerate
endmodule
