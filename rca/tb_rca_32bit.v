`timescale 1ns/1ps
`include "rca_Nbit.v"

module tb_rca_32_bit;

parameter N = 32;

// declare your signals as reg or wire
reg [N-1:0] A;
reg [N-1:0] B;
reg cin;
wire [N-1:0] S;
wire cout;

initial begin	
$monitor ("%d, %d", cout, S);
    A = 0; B = 0; cin = 0; #1;
// write the stimuli conditions
    A = 32'b1;
    B = 32'b1;
    cin = 0;
    #1;
end

rca_Nbit #(.N(N)) dut (.a(A), .b(B), .cin(cin), .S(S), .cout(cout));

initial begin
    $dumpfile("rca_32bit.vcd");
    $dumpvars(0, tb_rca_32_bit);
end

endmodule
