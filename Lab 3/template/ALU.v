//`timescale 1ns / 100ps
// change input RD1 to also effect to imm 
module ALU(A,B,OP,Out);

    input wire [31:0] A;
    input wire [31:0] B;
    input wire [3:0] OP;
    output wire [31:0] Out;

    reg [31:0] C;
    assign Out = C;
    
    initial C = 0;

    always @ (A, B, OP) begin
        case(OP)
        // ADD
            4'b0000 : C = A + B;
        // SUB
            4'b1000 : C = A - B;
        // SLL (logical left shift)
            4'b0001 : C = A << B[4:0];
        // SLT 
            4'b0010 : 
                begin
                    if ($signed(A) < $signed(B)) C = 1;
                    else C = 0;
                end
        // SLTU
        // SLTU rd, x0, rs2 sets rd to 1 if rs2 is not equal to zero, otherwise sets rd to zero
        // SLTIU rd, rs1, 1 sets rd to 1 if rs1 equals zero, otherwise sets rd to 0
            4'b0011 : 
                begin
                    if (A < B) C = 1;
                    else C = 0;
                end
        // XOR
            4'b0100 : C = A ^ B;
        // SRL (logical right shift) 
            4'b0101 : C = A >> B[4:0];
        // SRA (arithmetic right shift)
            4'b1101 : C = A >>> B[4:0];
        // OR
            4'b0110 : C = A | B;
        // AND
            4'b0111 : C = A & B;
        // BEQ
            4'b1001 :
		begin
			if (A == B) C = 1;
			else C = 0;
		end
        // BNE
            4'b1010 :
		begin
			if (A != B) C = 1;
			else C = 0;
		end
        // BLT
            4'b1011 :
		begin
			if ($signed(A) < $signed(B)) C = 1;
			else C = 0;
		end
        // BGE
            4'b1100 :
		begin
			if ($signed(A) >= $signed(B)) C = 1;
			else C = 0;
		end
        // BLTU
            4'b1110 :
		begin
			if (A < B) C = 1;
			else C = 0;
		end
        // BGEU
            4'b1111 :
		begin
			if (A >= B) C = 1;
			else C = 0;
		end
        endcase
    end
endmodule
