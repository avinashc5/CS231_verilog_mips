`timescale 1ns/1ps
`include "karatsuba.v"
module tb_iterative_karatsuba;
parameter N = 32;

reg clk;
reg rst;
reg enable;

reg [N-1:0] X;
reg [N-1:0] Y;

wire [(2*N - 1):0] Z;

reg [1:0] sel_x;
reg [1:0] sel_y;
reg  en_xhyh;
reg  en_xlyl;
reg  en_inter;

reg done;

reg [N:0] i;
reg [N:0] j;

reg [63:0] Z_actual;

always begin
    #5 clk = ~clk;
end

initial begin
    $display("time\t, clk\t rst\t, X\t, Y\t, Z\t ");
    // $monitor ("%g\t %b\t   %b\t     %d\t      %d\t      %d\t   ", $time, clk, rst, X, Y, Z);	

    clk = 1;
    rst = 0;

    /*
    #10 rst = 1;
    #10 rst = 0;
    
    
    #10 X = 4294967295;
       Y = 255;
        enable = 1;
    
    #100 enable = 1'b0;
    */
    
    
    #10 rst = 1;
    #10 rst  = 0;
    
    // #10 X = 3807872197;
    //    Y = 3574846122;
    // // #10 X = 10;
    // //     Y = 12;
        enable = 1'b1;   
        // #100;
        // $display("%b %b %b", X, Y, Z);
        // $finish;
        
        
//     #50 rst = 1;
//         enable = 1'b0;
        
    for (i=0; i<16; i=i+1) begin
        for (j=0; j<1; j=j+1) begin
            X = $random%4294967296;
            Y = $random%4294967296;
			X = 1100000;
			Y = 111;
			Z_actual = X*Y;
            enable = 1'b1; 
            #100 
            if (Z != X*Y) begin
               $display("ERROR");
               $display("%d %d %d, %d", X, Y, Z, Z_actual);
            end 
            #50 rst = 1;
            enable = 1'b0;
            #10 rst = 0;
            
        end    
    end                
    
    //#10 rst = 0;
    //#10 X = 334;
    //    Y = 324;    
    //    enable = 1'b1;
        
    #100 enable = 1'b0;
    
    #100
    #500 $finish;
end




iterative_karatsuba_32_16 ik(.clk(clk), .rst(rst), .enable(enable), .A(X), .B(Y), .C(Z) );


initial begin
    $dumpfile("iterative_karatsuba.vcd");
    $dumpvars(0,tb_iterative_karatsuba);
end

endmodule