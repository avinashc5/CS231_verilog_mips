module CLA_4bit(a, b, cin, sum, cout);
    input [3:0] a;
    input [3:0] b;
    input cin;
    output [3:0] sum;
    output cout;

    wire G;
    wire P;

    CLA_4bit_P_G clapg0(.a(a), .b(b), .cin(cin), .sum(sum), .P(P), .G(G));

    assign cout = G | (P & cin);

endmodule


module CLA_4bit_P_G(a, b, cin, sum, P, G);
    input [3:0] a;
    input [3:0] b;
    input cin;
    output [3:0] sum;
    output P;
    output G;

    wire [3:0] p;
    wire [3:0] g;
    wire [3:0] c;

    assign g = a & b;
    assign p = a ^ b;

    assign c[0] = cin;
    assign c[1] = g[0] | p[0] & c[0];
    assign c[2] = g[1] | p[1] & c[1];
    assign c[3] = g[2] | p[2] & c[2];

    assign sum = p ^ c;

    assign P = p[0] & p[1] & p[2] & p[3];
    assign G = g[3] | (p[3] & g[2]) | (p[3] & p[2] & g[1]) | (p[3] & p[2] & p[1] & g[0]);

endmodule


module lookahead_carry_unit_16_bit(P0, G0, P1, G1, P2, G2, P3, G3, cin, C4, C8, C12, C16, GF, PF);
    input P0, P1, P2, P3, G0, G1, G2, G3, cin;
    output C4, C8, C12, C16;
    output PF;
    output GF;

    assign C4 = G0 | (P0 & cin);
    assign C8 = G1 | (P1 & C4);
    assign C12 = G2 | (P2 & C8);
    assign C16 = G3 | (P3 & C12);

    assign GF = G3 | (P3 & G2) | (P3 & P2 & G1) | (P3 & P2 & P1 & G0);
    assign PF = P3 & P2 & P1 & P0;

endmodule


module CLA_16bit(a, b, cin, sum, cout, Pout, Gout);
    input [15:0] a;
    input [15:0] b;
    input cin;
    output [15:0] sum;
    output cout, Pout, Gout;
    wire [3:0] cout_intermed;
    wire [3:0] P;
    wire [3:0] G;
    wire C4, C8, C12, C16;

    CLA_4bit_P_G cla0(.a(a[3:0]), .b(b[3:0]), .cin(cin), .sum(sum[3:0]), .P(P[0]), .G(G[0]));
    CLA_4bit_P_G cla1(.a(a[7:4]), .b(b[7:4]), .cin(C4), .sum(sum[7:4]), .P(P[1]), .G(G[1]));
    CLA_4bit_P_G cla2(.a(a[11:8]), .b(b[11:8]), .cin(C8), .sum(sum[11:8]), .P(P[2]), .G(G[2]));
    CLA_4bit_P_G cla3(.a(a[15:12]), .b(b[15:12]), .cin(C12), .sum(sum[15:12]), .P(P[3]), .G(G[3]));

    lookahead_carry_unit_16_bit lcu0(.P0(P[0]), .G0(G[0]), .P1(P[1]), .G1(G[1]), .P2(P[2]), .G2(G[2]), .P3(P[3]), .G3(G[3]), .cin(cin), .C4(C4), .C8(C8), .C12(C12), .C16(C16), .GF(Gout), .PF(Pout));

    assign cout = C16;


endmodule


module lookahead_carry_unit_32_bit (P0, G0, P1, G1, cin, C16, C32, GF, PF);
    input P0, P1, G0, G1, cin;
    output C16, C32;
    output PF, GF;

    assign C16 = G0 | (P0 & cin);
    assign C32 = G1 | (P1 & C16);

    assign PF = P0 & P1;
    assign GF = G1 | (P1 & G0);

endmodule


module CLA_32bit(a, b, cin, sum, cout, Pout, Gout);

    input [31:0] a;
    input [31:0] b;
    input cin;
    output [31:0] sum;
    output cout;
    output Pout, Gout;

    wire P0, G0, P1, G1;
    wire C16, C32;

    CLA_16bit cla5(.a(a[15:0]), .b(b[15:0]), .cin(cin), .sum(sum[15:0]), .cout(), .Pout(P0), .Gout(G0));
    CLA_16bit cla6(.a(a[31:16]), .b(b[31:16]), .cin(C16), .sum(sum[31:16]), .cout(), .Pout(P1), .Gout(G1));

    lookahead_carry_unit_32_bit lcu1(.P0(P0), .G0(G0), .P1(P1), .G1(G1), .cin(cin), .C16(C16), .C32(C32), .GF(Gout), .PF(Pout));

    assign cout = C32;

endmodule
