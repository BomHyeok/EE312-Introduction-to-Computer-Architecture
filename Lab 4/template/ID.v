module ID(
    input wire IRWrite,
    input wire [31:0] INSTR,
    output wire [4:0] RF_RA1, RF_RA2, RF_WA1,
    output wire [31:0] IMM
    );

    reg [4:0] _RF_RA1, _RF_RA2, _RF_WA1;
    reg [31:0] _IMM;

    assign RF_RA1 = _RF_RA1;
    assign RF_RA2 = _RF_RA2;
    assign RF_WA1 = _RF_WA1;
    assign IMM = _IMM;

    initial begin
        _RF_RA1 = 0;
        _RF_RA2 = 0;
        _RF_WA1 = 0;
        _IMM = 0;
    end
    
    always @ (*) begin
        if (IRWrite) begin
            _IMM[11:0] = INSTR[31:20];
            if (INSTR[31]) _IMM[31:12] = 20'hfffff;
            else _IMM[31:12] = 0;
            _RF_WA1 = INSTR[11:7];
            _RF_RA1 = INSTR[19:15];
            _RF_RA2 = INSTR[24:20];

            case (INSTR[6:0])
                7'b1101111 : // JAL
                begin
                    _IMM[0] = 0;
                    _IMM[20:1] = {INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21]};
                    if (IMM[31] == 0) _IMM[31:21] = 0;
                    else _IMM[31:21] = 11'h7ff;
                //    _RF_WA1 = INSTR[11:7];
                    _RF_RA1 = 0;
                    _RF_RA2 = 0;
                end
                7'b1100111 : // JALR
                begin
                //    _IMM[11:0] = INSTR[31:20];
                //    if (INSTR[31]) _IMM[31:12] = 0;
                //    else _IMM[31:12] = 20'hfffff;
                //    _RF_WA1 = INSTR[11:7];
                //    _RF_RA1 = INSTR[19:15];
                    _RF_RA2 = 0;
                end
                7'b1100011 : // B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
                begin
                    _IMM[11:0] = {INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8]};
                    // don't need to change sign-extend part (only related with INSTR[31])
                    _IMM = _IMM << 1;
                    _RF_WA1 = 0;
                //    _RF_RA1 = INSTR[19:15];
                //    _RF_RA2 = INSTR[24:20];
                end
                7'b0000011 : // I Type Load LW
                begin
                //    _IMM[11:0] = INSTR[31:20];
                //    if (INSTR[31]) _IMM[31:12] = 0;
                //    else _IMM[31:12] = 20'hfffff;
                //    _RF_WA1 = INSTR[11:7];
                //    _RF_RA1 = INSTR[19:15];
                    _RF_RA2 = 0;
                end
                7'b0100011 : // SW
                begin
                    // _IMM[11:5] = INSTR[31:25];
                    // _IMM[4:0] = INSTR[11:7];
                    _IMM[11:0] = {INSTR[31:25], INSTR[11:7]};
                    // don't need to change sign-extend part (only related with INSTR[31])
                    _RF_WA1 = 0;
                //    _RF_RA1 = INSTR[19:15];
                //    _RF_RA2 = INSTR[24:20];
                end
                7'b0010011 : // I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
                begin
                //    _IMM[11:0] = INSTR[31:20];
                //    if (INSTR[31]) _IMM[31:12] = 0;
                //    else _IMM[31:12] = 20'hfffff;
                //    _RF_WA1 = INSTR[11:7];
                //    _RF_RA1 = INSTR[19:15];
                    _RF_RA2 = 0;
                end
                7'b0110011 : // R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
                begin
                    _IMM = 0;
                //    _RF_WA1 = INSTR[11:7];
                //    _RF_RA1 = INSTR[19:15];
                //    _RF_RA2 = INSTR[24:20];
                end
            endcase
        end
        
    end
endmodule
