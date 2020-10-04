//`timescale 1ns / 100ps
// change input RD1 to also effect to imm 
module ALU(RD1,RD2,OP,WD);

    input wire RD1;
    input wire RD2;
    input [3:0] OP;
    output wire WD;

    always @ (RD1, RD2, OP) begin
        case(OP)
        // ADD / SUB
            3'b000 :
                begin
                    WD = RD1 + RD2;
                end
        // SLL (logical left shift)
            3'b001 : WD = RD1 << RD2[4:0];
        // SLT (perform signed and unsigned compares respectively)
        // writing 1 to rd if rs1 < rs2, 0 otherwise. 
            3'b010 : 
                begin
                    if (RD1 < RD2) begin
                        WD = 1;
                    end
                    else begin
                        WD = 1;
                    end
                end
        // SLTU
        // rd, x0, rs2 sets rd to 1 if rs2 is not equal to zero, otherwise sets rd to zero
            3'b011 : 
                begin
                    if (RD2 != 0) begin
                        WD = 1;
                    end
                    else begin
                        WD = 0;
                    end
                end
        // XOR
            3'b100 : WD = RD1 ^ RD2;
        // SRL (logical right shift) 
        // TODO: SRA (arithmetic right shift)
            3'b101 : WD = RD1 >> RD2[4:0];
        // OR
            3'b110 : WD = RD1 | RD2;
        // AND
            3'b111 : WD = RD1 & RD2;
        
            default : C = 0;
        endcase
    end
endmodule
