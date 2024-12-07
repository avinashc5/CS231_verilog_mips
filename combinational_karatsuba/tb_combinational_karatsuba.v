`timescale 1ns/1ps
`include "combinational_karatsuba.v"
module tb_combinational_karatsuba;

parameter N = 16;

// declare your signals as reg or wire
reg [N-1:0] X, Y;
wire [2*N-1:0] Z;
wire [1:0] A, B;
wire [N-1:0] Z3;
integer i, j;

initial begin
$monitor("%d, %d, %d", X, Y, Z);
X = 0; Y = 0; #1;
// write the stimuli conditions
X = 16'b1111010011010111; Y = 16'b1110101011111; #1;

// for (i = 0; i < 256; i=i+7) begin
//     for (j = 0; j < 256; j=j+8) begin
//         X = i; Y = j; #1;
//     end
// end


end

karatsuba_16 dut (.X(X), .Y(Y), .Z(Z));
// karatsuba_8 dut3 (.X(X), .Y(Y), .Z(Z));
// karatsuba_4 dut1 (.X(X), .Y(Y), .Z(Z));
// adder4 dut2 (X, Y ^ 4'b1, Z)
// karatsuba_2 dut(X, Y, Z);
// rca_Nbit #(2) dut (2'b11, 2'b01, Z, 1'b0, cout);

initial begin
    $dumpfile("combinational_karatsuba.vcd");
    $dumpvars(0, tb_combinational_karatsuba);
end

endmodule
