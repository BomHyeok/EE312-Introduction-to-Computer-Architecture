module CTRL(
    input wire [31:0] INSTR,
	output wire [31:0] IMM, 
    output wire [4:0] RF_RA1, RF_RA2, RF_WA1,
    output wire [3:0] OP, D_MEM_BE,
	output wire [2:0] Lfunct,  
    output wire RF_WE, D_MEM_WEN, noRA1, isItype, isAUIPC, isLoad, isJump, isJAL, isBranch, isJALR
    );


    reg [31:0] _IMM;
    reg [4:0] _RF_WA1, _RF_RA1, _RF_RA2;
    reg [3:0] _D_MEM_BE, _OP;
    reg [2:0] _Lfunct;
    reg _RF_WE, _D_MEM_WEN, _noRA1, _isItype, _isAUIPC, _isLoad, _isJump, _isJAL, _isBranch, _isJALR;

    assign IMM = _IMM;
    assign RF_WE = _RF_WE;
	assign RF_WA1 = _RF_WA1;
	assign RF_RA1 = _RF_RA1;
	assign RF_RA2 = _RF_RA2;
    assign OP = _OP;
    assign D_MEM_WEN = _D_MEM_WEN;
    assign D_MEM_BE = _D_MEM_BE;
	assign noRA1 = _noRA1;
    assign isItype = _isItype;
	assign isAUIPC = _isAUIPC;
    assign isLoad = _isLoad;
    assign isJump = _isJump;
	assign isJAL = _isJAL;
	assign isJALR = _isJALR;
	assign isBranch = _isBranch;
    assign Lfunct = _Lfunct;

    initial begin
        _IMM = 0;
        _RF_WE = 0;
        _RF_WA1 = 0;
        _RF_RA1 = 0;
        _RF_RA2 = 0;
        _OP = 0;
        _D_MEM_WEN = 1;
        _D_MEM_BE = 0;
		_noRA1 = 0;
        _isItype = 0;
		_isAUIPC = 0;
		_isLoad = 0;
		_isJump = 0;
		_isJAL = 0;
		_isJALR = 0;
		_isBranch = 0;
		_Lfunct = 0;
    end
    always @ (*) begin
        case (INSTR[6:0])
			// LUI
			7'b0110111 :
			begin
				_IMM[31:12] = INSTR[31:12];
				_IMM[11:0] = 12'h000;
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_RF_RA1 = 0;
        		_RF_RA2 = 0;
        		_OP = 0;
                _D_MEM_WEN = 1;
				_D_MEM_BE = 0;
				_noRA1 = 1;
                _isItype = 1;
				_isAUIPC = 0;
                _isLoad = 0; 
				_isJump = 0;
				_isJAL = 0;
				_isJALR = 0;
				_isBranch = 0;
               	_Lfunct = 0; 
			end
					
			// AUIPC
			7'b0010111 :
			begin
				_IMM[31:12] = INSTR[31:12];
				_IMM[11:0] = 12'h000;
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_RF_RA1 = 0;
        		_RF_RA2 = 0;
				_OP = 0;
                _D_MEM_WEN = 1;
				_D_MEM_BE = 0;
				_noRA1 = 1;
                _isItype = 1;
				_isAUIPC = 1;
                _isLoad = 0; 
				_isJump = 0;
				_isJAL = 0;
				_isJALR = 0;
				_isBranch = 0;
               	_Lfunct = 0; 
			end
				
			// JAL
			7'b1101111 :
			begin
				_IMM[0] = 0;
				_IMM[20:1] = {INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21]};
				if (_IMM[20] == 0) _IMM[31:21] = 0;
        		else _IMM[31:21] = 11'h7ff;
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_RF_RA1 = 0;
				_RF_RA2 = 0;
				_OP = 0;
				_D_MEM_WEN = 1;
				_D_MEM_BE = 0;
				_noRA1 = 1;
				_isItype = 1;
				_isAUIPC = 0;
				_isLoad = 0;
				_isJump = 1;
				_isJAL = 1;
				_isJALR = 0;
				_isBranch = 0;
				_Lfunct = 0;				
			end
		
				
			// JALR
			7'b1100111 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_RF_RA1 = INSTR[19:15];
				_RF_RA2 = 0;
				_OP = 0;
				_D_MEM_WEN = 1;
				_D_MEM_BE = 0;
				_noRA1 = 0;
				_isItype = 1;
				_isAUIPC = 0;
				_isLoad = 0;
				_isJump = 1;
				_isJAL = 0;
				_isJALR = 1;
				_isBranch = 0;
				_Lfunct = 0;
			end
				
			// B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
			7'b1100011 :
			begin
				_IMM[12:1] = {INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8]};
				_IMM[0] = 0;
				if (_IMM[12] == 0) _IMM[31:13] = 0;
        		else _IMM[31:13] = 19'h7ffff;
				_RF_WE = 0;
				_RF_WA1 = 0;
				_RF_RA1 = INSTR[19:15];
				_RF_RA2 = INSTR[24:20];
                _D_MEM_WEN = 1;
				_D_MEM_BE = 0;
				_noRA1 = 0;
				_isItype = 0;
				_isAUIPC = 0;
				_isLoad = 0;
				_isJump = 0;
				_isJAL = 0;
				_isJALR = 0;
				_isBranch = 1;
				_Lfunct = 0;
				case(INSTR[14:12])
					3'b000: _OP = 4'b1001; //BEQ
					3'b001: _OP = 4'b1010; //BNE
					3'b100: _OP = 4'b1011; //BLT
					3'b101: _OP = 4'b1100; //BGE
					3'b110: _OP = 4'b1110; //BLTU
					3'b111: _OP = 4'b1111; //BGEU
				endcase		
			end
				
			// I Type Load (LB, LH, LW, LBU, LHU)
			7'b0000011 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_RF_RA1 = INSTR[19:15];
    		    _RF_RA2 = 0;
                _OP = 0;
				_D_MEM_WEN = 1;
     		   	_D_MEM_BE = 0;
				_noRA1 = 0;
                _isItype = 1;
				_isAUIPC = 0;
                _isLoad = 1;
				_isJump = 0;
				_isJAL = 0;
				_isJALR = 0;
				_isBranch = 0;
      	        _Lfunct = INSTR[14:12];
			end

			// Store (SB, SH, SW)
			7'b0100011 :
			begin
				_IMM[11:5] = INSTR[31:25];
				_IMM[4:0] = INSTR[11:7];
				_RF_WE = 0;
    		    _RF_WA1 = 0;
                _RF_RA1 = INSTR[19:15];
                _RF_RA2 = INSTR[24:20];
                _OP = 0;
				_D_MEM_WEN = 0;
                case (INSTR[14:12])
                    3'b000 : _D_MEM_BE = 4'b0001; // SB
                    3'b001 : _D_MEM_BE = 4'b0011; // SH
                    3'b010 : _D_MEM_BE = 4'b1111; // SW
                endcase
				_noRA1 = 0;
                _isItype = 1;
				_isAUIPC = 0;
                _isLoad = 0;
				_isJump = 0;
				_isJAL = 0;
				_isJALR = 0;
				_isBranch = 0;
				_Lfunct = 0;
			end
				

			// I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
			7'b0010011 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_RF_RA1 = INSTR[19:15];
				_RF_RA2 = 0;
				_OP[2:0] = INSTR[14:12];
				if (_OP == 4'b0101 && INSTR[30]) _OP[3] = 1;
				else _OP[3] = 0;
				_D_MEM_WEN = 1;
				_D_MEM_BE = 0;
				_noRA1 = 0;
				_isItype = 1;
				_isAUIPC = 0;
				_isLoad = 0;
				_isJump = 0;
				_isJAL = 0;
				_isJALR = 0;
				_isBranch = 0;
				_Lfunct = 0;
                
			end
		
			// R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
			7'b0110011 :
			begin
				_IMM = 0;
				_RF_WE = 1;
				_RF_WA1 = INSTR[11:7];
				_RF_RA1 = INSTR[19:15];
				_RF_RA2 = INSTR[24:20];
				_OP[2:0] = INSTR[14:12];
				if (INSTR[30]) _OP[3] = 1;
				else _OP[3] = 0;
				_D_MEM_WEN = 1;
      			_D_MEM_BE = 0;
				_noRA1 = 0;
				_isItype = 0;
				_isAUIPC = 0;
				_isLoad = 0;
				_isJump = 0;
				_isJAL = 0;
				_isJALR = 0;
				_isBranch = 0;
				_Lfunct = 0;
			end		
		endcase
    end
endmodule