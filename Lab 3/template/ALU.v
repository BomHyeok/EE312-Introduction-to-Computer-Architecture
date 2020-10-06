//`timescale 1ns / 100ps
// change input RD1 to also effect to imm 
module ALU(A,B,OP,Out);

    input wire [31:0] A;
    input wire [31:0] B;
    input wire [3:0] OP;
    output wire [31:0] Out;

    reg [31:0] C;
    assign Out = C;

    always @ (A, B, OP) begin
        case(OP)
        // ADD
            4'b0000 : C = A + B;
        // SUB
            4'b1000 : C = A + B;
        // SLL (logical left shift)
            4'b0001 : C = A << B[4:0];
        // SLT 
        // writing 1 to rd if rs1 < rs2, 0 otherwise. 
            4'b0010 : 
                begin
                    if ($signed(A) < $signed(B)) begin
                        C = 1;
                    end
                    else begin
                        C = 0;
                    end
                end
        // SLTU
        // rd, x0, rs2 sets rd to 1 if rs2 is not equal to zero, otherwise sets rd to zero
            4'b0011 : 
                begin
                    if (B != 0) begin
                        C = 1;
                    end
                    else begin
                        C = 0;
                    end
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
        
            default : C = 0;
        endcase
    end
endmodule
