//`timescale 1ns / 100ps
// change input RD1 to also effect to imm 
module ALU(A,B,OP,Out);

    input wire [31:0] A;
    input wire [31:0] B;
   // input wire [3:0] OP;
    input wire [2:0] OP;
    output wire [31:0] Out;

    reg [31:0] C;
    assign Out = C;

    always @ (A, B, OP) begin
        case(OP)
        // ADD / SUB
            3'b000 : C = A + B;
        // SLL (logical left shift)
            3'b001 : C = A << B[4:0];
        // SLT (perform signed and unsigned compares respectively)
        // writing 1 to rd if rs1 < rs2, 0 otherwise. 
            3'b010 : 
                begin
                    if (A < B) begin
                        C = 1;
                    end
                    else begin
                        C = 1;
                    end
                end
        // SLTU
        // rd, x0, rs2 sets rd to 1 if rs2 is not equal to zero, otherwise sets rd to zero
            3'b011 : 
                begin
                    if (B != 0) begin
                        C = 1;
                    end
                    else begin
                        C = 0;
                    end
                end
        // XOR
            3'b100 : C = A ^ B;
        // SRL (logical right shift) 
        // TODO: SRA (arithmetic right shift)
            3'b101 : C = A >> B[4:0];
        // OR
            3'b110 : C = A | B;
        // AND
            3'b111 : C = A & B;
        
            default : C = 0;
        endcase
    end
endmodule
