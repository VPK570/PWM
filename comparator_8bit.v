module comparator_1bit (
    input a, b,
    output L, Eq, G
);

assign L  = ~a & b;
assign Eq = ~(a ^ b);   // XNOR for equality
assign G  = a & ~b;
    
endmodule

module comparator_8bit (
    input  [7:0] A,
    input  [7:0] B,
    output L, Eq, G
);

wire [7:0] Lw, Eqw, Gw;

comparator_1bit c0 (A[0], B[0], Lw[0], Eqw[0], Gw[0]);
comparator_1bit c1 (A[1], B[1], Lw[1], Eqw[1], Gw[1]);
comparator_1bit c2 (A[2], B[2], Lw[2], Eqw[2], Gw[2]);
comparator_1bit c3 (A[3], B[3], Lw[3], Eqw[3], Gw[3]);
comparator_1bit c4 (A[4], B[4], Lw[4], Eqw[4], Gw[4]);
comparator_1bit c5 (A[5], B[5], Lw[5], Eqw[5], Gw[5]);
comparator_1bit c6 (A[6], B[6], Lw[6], Eqw[6], Gw[6]);
comparator_1bit c7 (A[7], B[7], Lw[7], Eqw[7], Gw[7]);

assign Eq = &Eqw;

assign G =
    Gw[7] |
    (Eqw[7] & Gw[6]) |
    (Eqw[7] & Eqw[6] & Gw[5]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Gw[4]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Eqw[4] & Gw[3]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Eqw[4] & Eqw[3] & Gw[2]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Eqw[4] & Eqw[3] & Eqw[2] & Gw[1]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Eqw[4] & Eqw[3] & Eqw[2] & Eqw[1] & Gw[0]);

assign L =
    Lw[7] |
    (Eqw[7] & Lw[6]) |
    (Eqw[7] & Eqw[6] & Lw[5]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Lw[4]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Eqw[4] & Lw[3]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Eqw[4] & Eqw[3] & Lw[2]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Eqw[4] & Eqw[3] & Eqw[2] & Lw[1]) |
    (Eqw[7] & Eqw[6] & Eqw[5] & Eqw[4] & Eqw[3] & Eqw[2] & Eqw[1] & Lw[0]);

endmodule