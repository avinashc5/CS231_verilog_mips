module half_adder(a, b, S, cout);
    input a, b;
    output S, cout;

    xor (S, a, b);
    assign cout = (a & b);
endmodule


module full_adder(a, b, cin, S, cout);

    input a, b, cin;
    output S, cout;
    wire S0, c0;

    half_adder h0(
        .a(a),
        .b(b),
        .S(S0),
        .cout(c0)
    );

    xor (S, S0, cin);
    assign cout = c0 | (b & cin) | (a & cin);

endmodule

module rca_Nbit #(parameter N = 32) (a, b, S, cin, cout);
    input [N-1:0] a;
    input [N-1:0] b;
    input cin;
    output [N-1:0] S;
    output cout;
    wire [N:0] c;

    assign c[0] = cin;

    generate 
        genvar i;
        for (i = 0; i < N; i = i + 1) begin
           full_adder f1(.a(a[i]), .b(b[i]), .cin(c[i]), .S(S[i]), .cout(c[i+1]));
        end
    endgenerate

    assign cout = c[N];

endmodule



module karatsuba_2 (X, Y, Z);
	input [1:0] X;
	input [1:0] Y;
	output [3:0] Z;

	wire Z0, Z1, Z2, Z3;

	assign Z0 = X[0] & Y[0];
	assign Z1 = X[0] & Y[1];
	assign Z2 = X[1] & Y[0];
	assign Z3 = X[1] & Y[1];

	wire [3:0] S0, S1;

	rca_Nbit #(4) a0({2'b0, Z1, 1'b0}, {3'b0, Z0}, S0, 1'b0, cout);
	rca_Nbit #(4) a1({1'b0, Z3, 2'b0}, {2'b0, Z2, 1'b0}, S1, 1'b0, cout);
	rca_Nbit #(4) a2(S0, S1, Z, 1'b0, cout);

endmodule

module karatsuba_4 (X, Y, Z);
	input [3:0] X;
	input [3:0] Y;
	output [7:0] Z;

	wire cout;
	wire [3:0] Z0, Z1, Z2, Z3, Z4;
	wire [1:0] A, B;

	wire a, b, c, d;
	wire [1:0] A_temp, B_temp, A_complement, B_complement;

	karatsuba_2 k20(X[1:0], Y[1:0], Z0);
	karatsuba_2 k21(X[3:2], Y[3:2], Z2);

	rca_Nbit #(2) a0(X[3:2], X[1:0] ^ 2'b11, A_temp, 1'b1, a);
	rca_Nbit #(2) a01(~A_temp, 2'b1, A_complement, 1'b0, c);

	assign A = (a)?(A_temp):(A_complement);

	rca_Nbit #(2) a1(Y[3:2], Y[1:0] ^ 2'b11, B_temp, 1'b1, b);
	rca_Nbit #(2) a11(~B_temp, 2'b1, B_complement, 1'b0, d);

	assign B = (b)?(B_temp):(B_complement);

	wire [3:0] Z1_temp, Z1_complement;
	karatsuba_2 k22(A, B, Z1_temp);

	rca_Nbit #(4) a00(~Z1_temp, 4'b1, Z1_complement, 1'b0, d);
	wire z6;
	assign Z1 = (a ^ b) ? Z1_complement : Z1_temp;
	assign z6 = ((a ^ b) & (A != 0) & (B != 0)) ? 1'b1 : 1'b0; // but should be 1'b0 for A or B is zero
	wire z3, z4, z5;
	rca_Nbit #(4) a2(Z2, Z0, Z3, 1'b0, z3);
	rca_Nbit #(5) a3({z3, Z3}, ~{z6, Z1}, {z4, Z4}, 1'b1, z5);

	wire [7:0] S0;

	rca_Nbit #(8) a4({1'b0, z4, Z4, 2'b0}, {4'b0, Z0}, S0, 1'b0, cout);
	rca_Nbit #(8) a5({Z2, 4'b0}, S0, Z, 1'b0, cout);

endmodule

module karatsuba_8 (X, Y, Z);
	input [7:0] X;
	input [7:0] Y;
	output [15:0] Z;

	wire cout;
	wire [7:0] Z0, Z1, Z2, Z3, Z4;
	wire [3:0] A, B;

	wire a, b, c, d;
	wire [3:0] A_temp, B_temp, A_complement, B_complement;

	karatsuba_4 k20(X[3:0], Y[3:0], Z0);
	karatsuba_4 k21(X[7:4], Y[7:4], Z2);

	rca_Nbit #(4) a0(X[7:4], ~X[3:0], A_temp, 1'b1, a);
	rca_Nbit #(4) a01(~A_temp, 4'b1, A_complement, 1'b0, c);

	assign A = (a)?(A_temp):(A_complement);

	rca_Nbit #(4) a1(Y[7:4], ~Y[3:0], B_temp, 1'b1, b);
	rca_Nbit #(4) a11(~B_temp, 4'b1, B_complement, 1'b0, d);

	assign B = (b)?(B_temp):(B_complement);

	wire [7:0] Z1_temp, Z1_complement;
	karatsuba_4 k22(A, B, Z1_temp);

	rca_Nbit #(8) a00(~Z1_temp, 8'b1, Z1_complement, 1'b0, d);
	wire z6;
	assign Z1 = (a ^ b) ? Z1_complement : Z1_temp;
	assign z6 = ((a ^ b) & ((A != 0) & (B != 0))) ? 1'b1 : 1'b0; // but should be 1'b0 for A or B is zero
	wire z3, z4, z5;
	rca_Nbit #(8) a2(Z2, Z0, Z3, 1'b0, z3);
	rca_Nbit #(9) a3({z3, Z3}, ~{z6, Z1}, {z4, Z4}, 1'b1, z5);

	wire [15:0] S0;

	rca_Nbit #(16) a4({3'b0, z4, Z4, 4'b0}, {8'b0, Z0}, S0, 1'b0, cout);
	rca_Nbit #(16) a5({Z2, 8'b0}, S0, Z, 1'b0, cout);

endmodule

module karatsuba_16 (X, Y, Z);
	input [15:0] X;
	input [15:0] Y;
	output [31:0] Z;

	wire cout;
	wire [15:0] Z0, Z1, Z2, Z3, Z4;
	wire [7:0] A, B;

	wire a, b, c, d;
	wire [7:0] A_temp, B_temp, A_complement, B_complement;

	karatsuba_8 k20(X[7:0], Y[7:0], Z0);
	karatsuba_8 k21(X[15:8], Y[15:8], Z2);

	rca_Nbit #(8) a0(X[15:8], ~X[7:0], A_temp, 1'b1, a);
	rca_Nbit #(8) a01(~A_temp, 8'b1, A_complement, 1'b0, c);

	assign A = (a) ? (A_temp) : (A_complement);

	rca_Nbit #(8) a1(Y[15:8], ~Y[7:0], B_temp, 1'b1, b);
	rca_Nbit #(8) a11(~B_temp, 8'b1, B_complement, 1'b0, d);

	assign B = (b) ? (B_temp) : (B_complement);

	wire [15:0] Z1_temp, Z1_complement;
	karatsuba_8 k22(A, B, Z1_temp);

	rca_Nbit #(16) a00(~Z1_temp, 16'b1, Z1_complement, 1'b0, d);
	wire z6;
	assign Z1 = (a ^ b) ? Z1_complement : Z1_temp;
	assign z6 = ((a ^ b) & ((A != 0) & (B != 0))) ? 1'b1 : 1'b0; // but should be 1'b0 for A or B is zero
	wire z3, z4, z5;
	rca_Nbit #(16) a2(Z2, Z0, Z3, 1'b0, z3);
	rca_Nbit #(17) a3({z3, Z3}, ~{z6, Z1}, {z4, Z4}, 1'b1, z5);

	wire [31:0] S0;

	rca_Nbit #(32) a4({7'b0, z4, Z4, 8'b0}, {16'b0, Z0}, S0, 1'b0, cout);
	rca_Nbit #(32) a5({Z2, 16'b0}, S0, Z, 1'b0, cout);

endmodule