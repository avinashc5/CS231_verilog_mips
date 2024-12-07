`timescale 1ns/1ps
`include "cla_Nbit.v"

module tb_cla_32bit;

parameter N = 32;     /*Change this to 16 if you want to test CLA 16-bit*/

// declare your signals as reg or wire
reg [N-1:0] a;
reg [N-1:0] b;
reg cin;
wire [N-1:0] S;
wire cout;
wire Pout;
wire Gout;
integer i, j;

initial begin

// write the stimuli conditions

    $monitor("%d, %d, %d", a, b, S);
    a = 0; b=0; cin = 0;
    for (i = 0; i < 256; i=i+7) begin
        for (j = 0; j < 256; j=j+8) begin
            a = i; b = j; #1;
        end
    end
end



CLA_32bit dut (.a(a), .b(b), .cin(cin), .sum(S), .cout(cout), .Pout(Pout), .Gout(Gout));
// CLA_4bit dut1 (.a(a[3:0]), .b(b[3:0]), .cin(cin), .sum(S[3:0]), .cout(cout));
// CLA_16bit dut2 (.a(a[15:0]), .b(b[15:0]), .cin(cin), .sum(S[15:0]), .cout(cout), .Pout(Pout), .Gout(Gout));

initial begin
    $dumpfile("cla_32bit.vcd");
    $dumpvars(0, tb_cla_32bit);
end

endmodule
