/* 32-bit simple karatsuba multiplier */

/*32-bit Karatsuba multipliction using a single 16-bit module*/

module iterative_karatsuba_32_16(clk, rst, enable, A, B, C);
    input clk;
    input rst;
    input [31:0] A;
    input [31:0] B;
    output [63:0] C;
    
    input enable;
    
    
    wire [1:0] sel_x;
    wire [1:0] sel_y;
    
    wire [1:0] sel_z;
    wire [1:0] sel_T;
    
    
    wire done;
    wire en_z;
    wire en_T;
    
    
    wire [32:0] h1;
    wire [32:0] h2;
    wire [63:0] g1;
    wire [63:0] g2;
    
    assign C = g2;
    reg_with_enable #(63) Z(.clk(clk), .rst(rst), .en(en_z), .X(g1), .O(g2) );  // Fill in the proper size of the register
    reg_with_enable #(32) T(.clk(clk), .rst(rst), .en(en_T), .X(h1), .O(h2) );  // Fill in the proper size of the register
    
    iterative_karatsuba_datapath dp(.clk(clk), .rst(rst), .X(A), .Y(B), .Z(g2), .T(h2), .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T), .en_z(en_z), .en_T(en_T), .done(done), .W1(g1), .W2(h1));
    iterative_karatsuba_control control(.clk(clk),.rst(rst), .enable(enable), .sel_x(sel_x), .sel_y(sel_y), .sel_z(sel_z), .sel_T(sel_T), .en_z(en_z), .en_T(en_T), .done(done));
    
endmodule

module iterative_karatsuba_datapath(clk, rst, X, Y, T, Z, sel_x, sel_y, en_z, sel_z, en_T, sel_T, done, W1, W2);
    input clk;
    input rst;
    input [31:0] X;    // input X
    input [31:0] Y;    // Input Y
    input [32:0] T;    // input which sums X_h*Y_h and X_l*Y_l (its also a feedback through the register)
    input [63:0] Z;    // input which calculates the final outcome (its also a feedback through the register)
    output [63:0] W1;  // Signals going to the registers as input
    output [32:0] W2;  // signals hoing to the registers as input
    

    input [1:0] sel_x;  // control signal 
    input [1:0] sel_y;  // control signal 
    
    input en_z;         // control signal 
    input [1:0] sel_z;  // control signal 
    input en_T;         // control signal 
    input [1:0] sel_T;  // control signal 
    
    input done;         // Final done signal
    
    
   
    
    //-------------------------------------------------------------------------------------------------
    
    // Write your datapath here
    //--------------------------------------------------------

wire [15:0] X_LO, X_HI, Y_LO, Y_HI;
wire [31:0] X_LOY_LO, X_HIY_HI;
wire [32:0] X_Y_MID_temp, X_Y_MID, X_Y_MID_comp;
wire [15:0] X_diff_temp, X_diff_comp2, X_diff_mod, Y_diff_temp, Y_diff_comp2, Y_diff_mod;
wire [32:0] X_diff_Y_diff;
wire ovx, ovy, ov_mid, x0, y0;
wire [31:0] mult_temp;
wire cout_comp;
wire [31:0] X_LOY_LO_PLUS_X_HIY_HI;
wire LO_PLUS_HI_carry, X_Y_MID_carry;
wire [31:0] X_diff_Y_diff_mod, X_diffY_diff_mod_comp;
wire [15:0] choose_X, choose_Y;
wire [63:0] WW;

assign X_LO = X[15:0];
assign X_HI = X[31:16];
assign Y_LO = Y[15:0];
assign Y_HI = Y[31:16];

// X_diff_mod is calculated
subtract_Nbit #(16) sub1(X_HI, X_LO, 1'b0, X_diff_temp, ovx, x0);
Complement2_Nbit #(16) comp1(X_diff_temp, X_diff_comp2, cout_comp);
assign X_diff_mod = x0 ? X_diff_temp : X_diff_comp2;

// Y_diff_mod is calculated
subtract_Nbit #(16) sub2(Y_HI, Y_LO, 1'b0, Y_diff_temp, ovy, y0);
Complement2_Nbit #(16) comp2(Y_diff_temp, Y_diff_comp2, cout_comp);
assign Y_diff_mod = y0 ? Y_diff_temp : Y_diff_comp2;

// X_LOY_LO or X_HIY_HI or X_diff_Y_diff_mod is calculated
//
assign choose_X = (sel_x == 2'b11) ? 16'b0 :
				  ((sel_x == 2'b01) ? X_LO :
				  ((sel_x == 2'b10) ? X_HI :
				  (sel_x == 2'b00) ? X_diff_mod :
				  16'b0));

assign choose_Y = (sel_x == 2'b11) ? 16'b0 :
				  ((sel_x == 2'b01) ? Y_LO :
				  ((sel_x == 2'b10) ? Y_HI :
				  (sel_x == 2'b00) ? Y_diff_mod :
				  16'b0));

mult_16 the_one_and_only(choose_X, choose_Y, mult_temp);

// Storing the incomplete multiplication in W1 i.e Z
assign W1 = (sel_x == 2'b01) ? {Z[63:32], mult_temp} :
			((sel_x == 2'b10) ? {mult_temp, Z[31:0]} :
			(sel_x == 2'b00) ? WW :
			64'b0);

// X_diff_Y_diff_mod is calculated
assign X_diff_Y_diff_mod = (sel_x == 2'b00) ? mult_temp : X_diff_Y_diff_mod;
// X_diff_Y_diff_mod_comp is calculated
Complement2_Nbit #(32) X_diffY_diff_mod_c(X_diff_Y_diff_mod, X_diffY_diff_mod_comp, cout_comp);

// Multiplication of the differences is calculated. Making it 33 bits because of the carry from the addition of the LO and HI terms of Z
assign X_diff_Y_diff = (x0 == y0) ? {1'b0, X_diff_Y_diff_mod} : {1'b1, X_diffY_diff_mod_comp};

// Addition of LO and HI terms in Z
adder_Nbit #(32) add1(Z[63:32], Z[31:0], 1'b0, X_LOY_LO_PLUS_X_HIY_HI, LO_PLUS_HI_carry);

// Subtract X_diff_Y_diff from the sum of LO and HI terms. This will be of 33 bits because of the carry of the addition of LO and HI terms
subtract_Nbit #(33) sub3({LO_PLUS_HI_carry, X_LOY_LO_PLUS_X_HIY_HI}, X_diff_Y_diff, 1'b0, X_Y_MID_temp, ov_mid, X_Y_MID_carry);

// X_Y_MID is calculated
Complement2_Nbit #(33) comp3(X_Y_MID_temp, X_Y_MID_comp, cout_comp);
assign X_Y_MID = X_Y_MID_carry ? X_Y_MID_temp : X_Y_MID_comp;

// Storing the X_Y_MID in W2
assign W2 = X_Y_MID;

// Adding the mid term with the LO and HI terms in Z with appropriate shift
adder_Nbit #(64) add_final(Z, {15'b0, X_Y_MID, 16'b0}, 1'b0, WW, LO_PLUS_HI_carry);







// assign W1 = X * Y;




endmodule


module iterative_karatsuba_control(clk,rst, enable, sel_x, sel_y, sel_z, sel_T, en_z, en_T, done);
    input clk;
    input rst;
    input enable;
    
    output reg [1:0] sel_x;
    output reg [1:0] sel_y;
    
    output reg [1:0] sel_z;
    output reg [1:0] sel_T;    
    
    output reg en_z;
    output reg en_T;
    
    
    output reg done;
    
    reg [5:0] state, nxt_state;
    // States
    parameter S0 = 6'b000001;
	parameter S1 = 6'b000010;
	parameter S2 = 6'b000100;
	parameter S3 = 6'b001000;
	parameter S4 = 6'b010000;
	parameter S5 = 6'b100000;
	parameter S6 = 6'b110000;

    always @(clk) begin
        if (rst) begin
            state <= S0;
        end
        else if (enable) begin
            state <= nxt_state;
        end
    end
    

    always@(clk) begin
        case(state) 
			S0: 
				begin
					// $display("S0");
					// Write your output and next state equations here
					nxt_state <= S1;
					done <= 1'b0;
				end
            S1: 
                begin
					// $display("S1");
					// Write your output and next state equations here
					sel_x <= 2'b11;
					en_z <= 1'b1;
					nxt_state <= S2;
                end
			// Define the rest of the states
			S2:
				begin
					// $display("S2");
					en_T <= 1'b0;
					en_z <= 1'b1;
					sel_x <= 2'b01;
					nxt_state <= S3;
				end
			
			S3:
				begin
					// $display("S3");
					sel_x <= 2'b10;
					en_z <= 1'b1;
					en_T <= 1'b0;
					nxt_state <= S4;
				end

			S4:
				begin
					// $display("S4");
					sel_x <= 2'b00;
					en_z <= 1'b1;
					en_T <= 1'b0;
					nxt_state <= S5;
				end

			S5:
				begin
					// $display("S5");
					done <= 1'b1;
					nxt_state <= S5;
					en_z <= 1'b0;
				end

			S6:
				begin
					done <= 1'b1;
					en_z <= 1'b0;
					nxt_state <= S6;
				end

            default: 
                begin
					$display("Default");
				// Don't forget the default
					state <= S0;
                end            
        endcase
        
    end

endmodule


module reg_with_enable #(parameter N = 32) (clk, rst, en, X, O );
    input [N:0] X;
    input clk;
    input rst;
    input en;
    output [N:0] O;
    
    reg [N:0] R;
    
    always@(posedge clk) begin
        if (rst) begin
            R <= {N{1'b0}};
        end
        if (en) begin
            R <= X;
        end
    end
    assign O = R;
endmodule







/*-------------------Supporting Modules--------------------*/
/*------------- Iterative Karatsuba: 32-bit Karatsuba using a single 16-bit Module*/

module mult_16(X, Y, Z);
input [15:0] X;
input [15:0] Y;
output [31:0] Z;

assign Z = X*Y;

endmodule


module mult_17(X, Y, Z);
input [16:0] X;
input [16:0] Y;
output [33:0] Z;

assign Z = X*Y;

endmodule

module full_adder(a, b, cin, S, cout);
input a;
input b;
input cin;
output S;
output cout;

assign S = a ^ b ^ cin;
assign cout = (a&b) ^ (b&cin) ^ (a&cin);

endmodule


module check_subtract (A, B, C);
 input [7:0] A;
 input [7:0] B;
 output [8:0] C;
 
 assign C = A - B; 
endmodule



/* N-bit RCA adder (Unsigned) */
module adder_Nbit #(parameter N = 32) (a, b, cin, S, cout);
input [N-1:0] a;
input [N-1:0] b;
input cin;
output [N-1:0] S;
output cout;

wire [N:0] cr;  

assign cr[0] = cin;


generate
    genvar i;
    for (i = 0; i < N; i = i + 1) begin
        full_adder addi (.a(a[i]), .b(b[i]), .cin(cr[i]), .S(S[i]), .cout(cr[i+1]));
    end
endgenerate    


assign cout = cr[N];

endmodule


module Not_Nbit #(parameter N = 32) (a,c);
input [N-1:0] a;
output [N-1:0] c;

generate
genvar i;
for (i = 0; i < N; i = i+1) begin
    assign c[i] = ~a[i];
end
endgenerate 

endmodule


/* 2's Complement (N-bit) */
module Complement2_Nbit #(parameter N = 32) (a, c, cout_comp);

input [N-1:0] a;
output [N-1:0] c;
output cout_comp;

wire [N-1:0] b;
wire ccomp;

Not_Nbit #(.N(N)) compl(.a(a),.c(b));
adder_Nbit #(.N(N)) addc(.a(b), .b({ {N-1{1'b0}} ,1'b1 }), .cin(1'b0), .S(c), .cout(ccomp));

assign cout_comp = ccomp;

endmodule


/* N-bit Subtract (Unsigned) */
module subtract_Nbit #(parameter N = 32) (a, b, cin, S, ov, cout_sub);

input [N-1:0] a;
input [N-1:0] b;
input cin;
output [N-1:0] S;
output ov;
output cout_sub;

wire [N-1:0] minusb;
wire cout;
wire ccomp;

Complement2_Nbit #(.N(N)) compl(.a(b),.c(minusb), .cout_comp(ccomp));
adder_Nbit #(.N(N)) addc(.a(a), .b(minusb), .cin(1'b0), .S(S), .cout(cout));

assign ov = (~(a[N-1] ^ minusb[N-1])) & (a[N-1] ^ S[N-1]);
assign cout_sub = cout | ccomp;

endmodule



/* n-bit Left-shift */

module Left_barrel_Nbit #(parameter N = 32)(a, n, c);

input [N-1:0] a;
input [$clog2(N)-1:0] n;
output [N-1:0] c;


generate
genvar i;
for (i = 0; i < $clog2(N); i = i + 1 ) begin: stage
    localparam integer t = 2**i;
    wire [N-1:0] si;
    if (i == 0) 
    begin 
        assign si = n[i]? {a[N-t:0], {t{1'b0}}} : a;
    end    
    else begin 
        assign si = n[i]? {stage[i-1].si[N-t:0], {t{1'b0}}} : stage[i-1].si;
    end
end
endgenerate

assign c = stage[$clog2(N)-1].si;

endmodule



