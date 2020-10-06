module CTRL(
    input wire [31:0] INSTR,
//    input wire [3:0] OP,
//    input wire [31:0] PC, RF_RD1,
    output wire [2:0] OP, Lfunct,   
    output wire [31:0] RF_WD, IMM, 
    output wire [4:0] RF_RA1, RF_RA2, RF_WA1,
    output wire [3:0] D_MEM_BE,
    output wire RF_WE, isItype, isLoad, isJump, D_MEM_WEN
    );


    reg [31:0] _IMM, _RF_RA1, _RF_RA2, _RF_WD, Target, EFFECTIVE_ADDR, _OUTPUT_PORT;
//	reg [31:0] _PC;
    reg [4:0] _RF_WA1;
    reg [3:0] _D_MEM_BE;
//    reg [3:0] _OP;
    reg [2:0] _OP, _Lfunct;
    reg _RF_WE, _D_MEM_WEN, _isItype, _isLoad, _isJump;

    assign IMM = _IMM;
//    assign PC = _PC;
    assign RF_WE = _RF_WE;
	assign RF_WD = _RF_WD;
	assign RF_WA1 = _RF_WA1;
	assign RF_RA1 = _RF_RA1;
	assign RF_RA2 = _RF_RA2;
    assign OP = _OP;
    assign D_MEM_WEN = _D_MEM_WEN;
    assign D_MEM_BE = _D_MEM_BE;
    assign isItype = _isItype;
    assign isLoad = _isLoad;
    assign isJump = _isJump;
    assign Lfunct = _Lfunct;

    initial begin
        _IMM = 0;
    //    _PC = 0;
        _RF_WE = 0;
        _RF_WD = 0;
        _RF_WA1 = 0;
        _RF_RA1 = 0;
        _RF_RA2 = 0;
        _OP = 0;
        _D_MEM_WEN = 1;
        _D_MEM_BE = 0;
        _isItype = 0;
    end
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
                _D_MEM_WEN = 1;
			end
					
			// AUIPC
			7'b0010111 :
			begin
				_IMM[31:12] = INSTR[31:12];
				_IMM[11:0] = 0;
				_RF_WA1 = INSTR[11:7];
                _D_MEM_WEN = 1;
			end
				
			// JAL
			7'b1101111 :
			begin
				_IMM[20:0] = {INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21]};
				_RF_WA1 = INSTR[11:7];
                _D_MEM_WEN = 1;
                /*
				Target = PC + _IMM;
				_RF_WD = PC + 4;
				_PC = Target;
                */
			end
				
			// JALR
			7'b1100111 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_RA1 = INSTR[19:15];
				_RF_WA1 = INSTR[11:7];
                _D_MEM_WEN = 1;
			/*	Target = (RF_RD1 + _IMM) & 32'hfffffffe;
				_RF_WD = PC + 4;
				_PC = Target;
                */
			end
				
			// B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
			7'b1100011 :
			begin
				_IMM[12:0] = {INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8]};
				_RF_RA1 = INSTR[19:15];
				_RF_RA2 = INSTR[24:20];
				_OP = INSTR[14:12];
                _D_MEM_WEN = 1;
			end
				

			// I Type Load (LB, LH, LW, LBU, LHU)
			7'b0000011 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_WA1 = INSTR[11:7];
			//	EFFECTIVE_ADDR = _IMM + RF_RD1; // ALU add
			//	_RF_WD = MEM[d_translate(EFFECTIVE_ADDR)];
                _OP = 0;
                _isItype = 1;
                _isLoad = 1;
                _Lfunct = INSTR[14:12];
                _RF_WE = 1;
                _D_MEM_WEN = 1;
			end
				
			// Store (SB, SH, SW)
			7'b0100011 :
			begin
				_IMM[11:5] = INSTR[31:25];
				_IMM[4:0] = INSTR[11:7];
                _RF_RA1 = INSTR[19:15];
                _RF_RA2 = INSTR[24:20];
                _OP = 0;
                _isItype = 1;
                _isLoad = 0;
                _RF_WE = 0;
                _D_MEM_WEN = 0;
                // mem address = d_translate(EFFECTIVE_ADDR)
                // store RF_RD2 in mem address
                case (INSTR[14:12])
                    3'b000 : _D_MEM_BE = 4'b0001;
                    3'b001 : _D_MEM_BE = 4'b0011;
                    3'b010 : _D_MEM_BE = 4'b1111;
                endcase

			end
				

			// I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
			7'b0010011 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_RA1 = INSTR[19:15];
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_OP = INSTR[14:12];
				_isItype = 1;
                _D_MEM_WEN = 1;
			//	ALU(IMM, RF_RD1, OP, RF_WD);
			end
				
			// R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
			7'b0110011 :
			begin
				_RF_RA1 = INSTR[19:15];
				_RF_RA2 = INSTR[24:20];
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_OP = INSTR[14:12];
				_isItype = 0;
                _D_MEM_WEN = 1;
			//	ALU(RF_RD1, RF_RD2, OP, RF_WD);
			end
				
			default: _RF_WD = 0; // need to modify
		endcase
    end
endmodule