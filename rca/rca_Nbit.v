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

module rca_Nbit #(parameter N = 32) (a, b, cin, S, cout);
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


