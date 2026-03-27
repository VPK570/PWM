module dff_1bit (
    output reg q,
    input wire d,
    input wire clk,
    input wire rst_n
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= 1'b0; // Active-low reset
        end else begin
            q <= d;    // On positive clock edge, q gets the value of d
        end
    end

endmodule

module dff_8bit (
    output wire [7:0] q,
    input  wire [7:0] d,
    input  wire clk,
    input  wire rst_n
);

genvar i;
generate
    for (i = 0; i < 8; i = i + 1) begin : dff_array
        dff_1bit dff_inst (
            .q(q[i]),
            .d(d[i]),
            .clk(clk),
            .rst_n(rst_n)
        );
    end
endgenerate

endmodule