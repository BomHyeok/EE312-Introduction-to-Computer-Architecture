`timescale 1ns / 100ps

module ALU(A,B,OP,C,Cout);

	input [15:0]A;
	input [15:0]B;
	input [3:0]OP;
	output [15:0]C;
	output Cout;

	/*reg [15:0]A;
	reg [15:0]B;
	reg [3:0]OP;
	*/
	reg [15:0]C;
	reg Cout;

	//TODO

	always @ (A, B, OP) begin
		Cout = 0;
		case(OP)
		// ADD
			4'b0000 : C = A + B;
		// SUB
			4'b0001 : C = A - B;
		// AND
			4'b0010 : C = A & B;
		// OR
			4'b0011 : C = A | B;
		// NAND
			4'b0100 : C = A ~& B;
		// NOR
			4'b0101 : C = A ~| B;
		// XOR
			4'b0110 : C = A ^ B;
		// XNOR
			4'b0111 : C = A ^~ B;
		// ID
			4'b1000 : C = A;
		// NOT
			4'b1001 : C = ~A;
		// LRS
			4'b1010 : C = A >> 1;
		// ARS
			4'b1011 : 
				begin 
					$display (A[15]);
					Cout = A[15];
					C = A >> 1;
					C[15] = Cout;
					Cout = 0;
				end

		// RR
	//		4'b1100 :
		// LLS
			4'b1101 : C = A << 1;
		// ALS
			4'b1110 : C = A << 1;
		// RL
	//		4'b1111 :
			default : C = 0;
		endcase
	end


	
endmodule



