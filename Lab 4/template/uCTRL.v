module uCTRL(
    input wire [31:0] INSTR,
	output wire [31:0] IMM, 
    output wire [4:0] RF_RA1, RF_RA2, RF_WA1,
    output wire [3:0] OP, D_MEM_BE,
    output wire RF_WE, D_MEM_WEN, isItype, isLoad, isJump, isJAL, isBranch, isJALR
    );


    reg [31:0] _IMM;
    reg [4:0] _RF_WA1, _RF_RA1, _RF_RA2;
    reg [3:0] _D_MEM_BE, _OP;
    reg _RF_WE, _D_MEM_WEN, _isItype, _isLoad, _isJump, _isJAL, _isBranch, _isJALR;

	reg [3:0] _ALUOp;
	reg _PCWriteCond, _PCWrite, _IorD, _MemRead, _MemWrite, _MemtoReg, _IRWrite, _PCSource, _ALUSrcB, _ALUSrcA, _RegWrite, _RegDst;

    assign IMM = _IMM;
    assign RF_WE = _RF_WE;
	assign RF_WA1 = _RF_WA1;
	assign RF_RA1 = _RF_RA1;
	assign RF_RA2 = _RF_RA2;
    assign OP = _OP;
    assign D_MEM_WEN = _D_MEM_WEN;
    assign D_MEM_BE = _D_MEM_BE;
    assign isItype = _isItype;
    assign isLoad = _isLoad;
    assign isJump = _isJump;
	assign isJAL = _isJAL;
	assign isJALR = _isJALR;
	assign isBranch = _isBranch;

    initial begin
        _IMM = 0;
        _RF_WE = 0;
        _RF_WA1 = 0;
        _RF_RA1 = 0;
        _RF_RA2 = 0;
        _OP = 0;
        _D_MEM_WEN = 1;
        _D_MEM_BE = 0;
        _isItype = 0;
		_isLoad = 0;
		_isJump = 0;
		_isJAL = 0;
		_isJALR = 0;
		_isBranch = 0;
    end
    always @ (*) begin
		case (uPC)
			3'b000 : // IF
			begin
				_PCWrite = 1; // PC Update
				_MemRead = 1;
				_IorD = 0;
				uPCadd
				_Updated_uPC = uPC + 1;
			end
			3'b001 : // ID
			begin
				_IRWrite = 1;
				uPCadd
				_Updated_uPC = uPC + 1;
			end
			3'b010 : // EX
			begin
				_ALUSrcA = 1; // 0: PC, 1: RA1
				_ALUSrcB = 1; // 0: RA2, 1: IMM
				_ALUOp = 0;
				_PCSrc = 2'b00; // PC = PC + 4
				case (INSTR[6:0])
					7'b1101111 : // JALbegin
						_ALUSrcA = 0;
						// _ALUSrcB = 1;
						// _ALUOp = 0;
						_PCSrc = 2'b01; // PC = ALU_RESULT
						_Updated_uPC = uPC + 2;
					end
					7'b1100111 : // JALR
					begin
						// _ALUSrcA = 1; 
						// _ALUSrcB = 1;
						// _ALUOp = 0;
						_PCSrc = 2'b10; // PC = ALU_RESULT & 32'hfffffffe
						_Updated_uPC = uPC + 2;
					end
					7'b1100011 : // B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
					begin
						_ALUSrcA = 0;
						// _ALUSrcB = 1;
						case(INSTR[14:12])
							3'b000: _ALUOp = 4'b1001; //BEQ
							3'b001: _ALUOp = 4'b1010; //BNE
							3'b100: _ALUOp = 4'b1011; //BLT
							3'b101: _ALUOp = 4'b1100; //BGE
							3'b110: _ALUOp = 4'b1110; //BLTU
							3'b111: _ALUOp = 4'b1111; //BGEU
						endcase	
						_PCSrc = 2'b11; // PC depends on branch cond
						_Updated_uPC = 0;
					end
					7'b0000011 : // I Type Load LW
					begin
						// _ALUSrcA = 1;
						// _ALUSrcB = 1;
						// _ALUOp = 0;
						// _PCSrc = 2'b00; // PC = PC + 4
						_Updated_uPC = uPC + 1;
					end
					7'b0100011 : // SW
					begin
						// _ALUSrcA = 1;
						// _ALUSrcB = 1;
						// _ALUOp = 0;
						// _PCSrc = 2'b00; // PC = PC + 4
						_Updated_uPC = uPC + 1;
					end
					7'b0010011 : // I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
					begin
						// _ALUSrcA = 1;
						// _ALUSrcB = 1;
						_ALUOp[2:0] = INSTR[14:12];
						if (_ALUOp == 4'b0101 && INSTR[30]) _ALUOp[3] = 1;
						else _ALUOp[3] = 0;
						// _PCSrc = 2'b00; // PC = PC + 4
						_Updated_uPC = uPC + 2;
					end
					7'b0110011 : // R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
					begin
						// _ALUSrcA = 1;
						_ALUSrcB = 0;
						_ALUOp[2:0] = INSTR[14:12];
						if (INSTR[30]) _ALUOp[3] = 1;
						else _ALUOp[3] = 0;
						// _PCSrc = 2'b00; // PC = PC + 4
						_Updated_uPC = uPC + 2;
					end
				endcase
			end
			3'b011 : // MEM
			begin
				_MemRead = 1;
				_IorD = 1;
				_Updated_uPC = uPC + 1;
				if (INSTR[6:0] == 7'b0100011) begin //SW
					_D_MEM_WEN = 0;
					_D_MEM_BE = 4'b1111;
					_Updated_uPC = 0;
					if (INSTR[14:12] != 3'b010) $display("Invalid Instruction: Only deal with SW");
				end
			end
			3'b100 : // WB
			begin
				_RF_WE = 1;
				// JAL and JALR
				if (INSTR[6:0] == 7'b1101111 || INSTR[6:0] == 7'b1100111) begin
					_RWSrc = 0; // PC + 4
				end
				// LW
				else if (INSTR[6:0] ==7'b0000011)  begin
					_RWSrc = 1; // D_MEM_DI
				end
				// I-type and R-type
				else begin
					_RWSrc = 2; // ALU_RESULT
				end
				_Updated_uPC = 0;
			end
		endcase
    end
endmodule