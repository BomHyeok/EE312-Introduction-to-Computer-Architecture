module ID(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire S,
    output wire [31:0] Out
    );

    reg [31:0] TEMP;
    assign Out = TEMP;
    initial TEMP = 0;
    
    always @ (*) begin
        if (IRWrite) begin
            case (INSTR[6:0])
                7'b1101111 : // JAL
                begin
                    _IMM[0] = 0;
                    _IMM[20:1] = {INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21]};
                    if (_IMM[20] == 0) _IMM[31:21] = 0;
                    else _IMM[31:12] = 11'h7ff;
                    _RF_WE = 1;
                    _RF_WA1 = INSTR[11:7];
                    _RF_RA1 = 0;
                    _RF_RA2 = 0;
                    _OP = 0;
                end
                7'b1100111 : // JALR
                begin
                    _IMM[11:0] = INSTR[31:20];
                    _RF_WE = 1;
                    _RF_WA1 = INSTR[11:7];
                    _RF_RA1 = INSTR[19:15];
                    _RF_RA2 = 0;
                    _OP = 0;
                end
                7'b1100011 : // B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
                begin
                    _IMM[12:1] = {INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8]};
                    _IMM[0] = 0;
                    if (_IMM[12] == 0) _IMM[31:13] = 0;
                    else _IMM[31:13] = 19'h7ffff;
                    _RF_WE = 0;
                    _RF_WA1 = 0;
                    _RF_RA1 = INSTR[19:15];
                    _RF_RA2 = INSTR[24:20];
                end
                7'b0000011 : // I Type Load LW
                begin
                    _IMM[11:0] = INSTR[31:20];
                    _RF_WE = 1;
                    _RF_WA1 = INSTR[11:7];
                    _RF_RA1 = INSTR[19:15];
                    _RF_RA2 = 0;
                    _OP = 0;
                end
                7'b0100011 : // SW
                begin
                    // _IMM[11:5] = INSTR[31:25];
                    // _IMM[4:0] = INSTR[11:7];
                    _IMM[11:0] = {INSTR[31:25], INSTR[11:7]};
                    _RF_WE = 0;
                    _RF_WA1 = 0;
                    _RF_RA1 = INSTR[19:15];
                    _RF_RA2 = INSTR[24:20];
                    _OP = 0;
                end
                7'b0010011 : // I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
                begin
                    _IMM[11:0] = INSTR[31:20];
                    _RF_WE = 1;
                    _RF_WA1 = INSTR[11:7];
                    _RF_RA1 = INSTR[19:15];
                    _RF_RA2 = 0;
                    _OP[2:0] = INSTR[14:12];
                    if (_OP == 4'b0101 && INSTR[30]) _OP[3] = 1;
                    else _OP[3] = 0;
                end
                7'b0110011 : // R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
                begin
                    _IMM = 0;
                    _RF_WE = 1;
                    _RF_WA1 = INSTR[11:7];
                    _RF_RA1 = INSTR[19:15];
                    _RF_RA2 = INSTR[24:20];
                    _OP[2:0] = INSTR[14:12];
                    if (INSTR[30]) _OP[3] = 1;
                    else _OP[3] = 0;
                end
            endcase
        end
        
    end
endmodule
