module CTRL(
    input wire [31:0] INSTR, PC, ALUSRC, RF_RD1,
    input wire [4:0] RF_RA1, RF_RA2, RF_WA1,
    input wire [3:0] OP,
    input wire INSTR_TYPE,
    output wire [31:0] RF_WD, IMM
    );


    reg [31:0] _IMM, _PC, _RF_RA1, _RF_RA2, _RF_WD, Target, EFFECTIVE_ADDR, _ALUSRC, _OUTPUT_PORT;
	reg [4:0] _RF_WA1;
    reg [3:0] _OP;
    reg _RF_WE, _INSTR_TYPE;

    assign IMM = _IMM;
    assign PC = _PC;
    assign RF_WE = _RF_WE;
	assign RF_WD = _RF_WD;
	assign RF_WA1 = _RF_WA1;
	assign RF_RA1 = _RF_RA1;
	assign RF_RA2 = _RF_RA2;
	assign ALUSRC = _ALUSRC;
    assign INSTR_TYPE = _INSTR_TYPE;
    assign OP = _OP;
    
    always @ (*) begin
        case (INSTR[6:0])
			// LUI
			7'b0110111 :
			begin
				_IMM[31:12] = INSTR[31:12];
				_IMM[11:0] = 12'h000;
				_RF_WA1 = INSTR[11:7];
				_RF_WE = 1;
				_RF_WD = _IMM;
			end
					
			// AUIPC
			7'b0010111 :
			begin
				_IMM[31:12] = INSTR[31:12];
				_IMM[11:0] = 0;
				_RF_WA1 = INSTR[11:7];
			end
				
			// JAL
			7'b1101111 :
			begin
				_IMM[20:0] = {INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21]};
				_RF_WA1 = INSTR[11:7];
				Target = PC + _IMM;
				_RF_WD = PC + 4;
				_PC = Target;
			end
				
			// JALR
			7'b1100111 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_RA1 = INSTR[19:15];
				_RF_WA1 = INSTR[11:7];
				Target = (RF_RD1 + _IMM) & 32'hfffffffe;
				_RF_WD = PC + 4;
				_PC = Target;
			end
				
			// B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
			7'b1100011 :
			begin
				_IMM[12:0] = {INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8]};
				_RF_RA1 = INSTR[19:15];
				_RF_RA2 = INSTR[24:20];
				_OP = INSTR[14:12];
			end
				

			// I Type Load (LB, LH, LW, LBU, LHU)
			7'b0000011 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_WA1 = INSTR[11:7];
				EFFECTIVE_ADDR = _IMM + RF_RD1; // ALU add
			//	_RF_WD = MEM[d_translate(EFFECTIVE_ADDR)];
				_PC = PC + 4;
			end
				
			// Store (SB, SH, SW)
			7'b0100011 :
			begin
				_IMM[11:5] = INSTR[31:25];
				_IMM[4:0] = INSTR[11:7];
                _RF_RA1 = INSTR[19:15];
                _RF_RA2 = INSTR[24:20];
            //    S_OP = INSTR[14:12];
                EFFECTIVE_ADDR = _IMM + RF_RD1; // ALU add
                // Memwrite 1
                // mem address = d_translate(EFFECTIVE_ADDR)
                // store RF_RD2 in mem address
                _PC = PC + 4;

			end
				

			// I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
			7'b0010011 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_RA1 = INSTR[19:15];
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_OP = INSTR[14:12];
				_INSTR_TYPE = 1;
			//	ALU(IMM, RF_RD2, OP, RF_WD);
			end
				
			// R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
			7'b0110011 :
			begin
				_RF_RA1 = INSTR[19:15];
				_RF_RA2 = INSTR[24:20];
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_OP = INSTR[14:12];
				_INSTR_TYPE = 0;
			//	ALU(RF_RD1, RF_RD2, OP, RF_WD);
			end
				
			default: _RF_WD = 0; // need to modify
		endcase
    end
endmodule