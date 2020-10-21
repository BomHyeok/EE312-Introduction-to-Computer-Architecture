module uCTRL(
    input wire [31:0] INSTR,
	input wire [2:0] uPC,
    output wire [3:0] ALUOp, D_MEM_BE,
	output wire [2:0] Updated_uPC,
	output wire [1:0] PCSrc, RWSrc, 
    output wire RF_WE, D_MEM_WEN, PCWrite, isBranch, MemRead, IorD, IRWrite, ALUSrcA, ALUSrcB, INSTR_FINISH, ALUWrite
    );

    reg [3:0] _ALUOp, _D_MEM_BE;
	reg [2:0] _Updated_uPC;
	reg [1:0] _PCSrc, _RWSrc;
    reg _RF_WE, _D_MEM_WEN, _PCWrite, _isBranch;
	reg _MemRead, _IorD, _IRWrite, _ALUSrcA, _ALUSrcB, _INSTR_FINISH, _ALUWrite;

	assign Updated_uPC = _Updated_uPC;
    assign RF_WE = _RF_WE;
    assign ALUOp = _ALUOp;
    assign D_MEM_WEN = _D_MEM_WEN;
    assign D_MEM_BE = _D_MEM_BE;
	assign PCWrite = _PCWrite;
	assign isBranch = _isBranch;
	assign MemRead = _MemRead;
	assign IorD = _IorD;
	assign IRWrite = _IRWrite;
	assign PCSrc = _PCSrc;
	assign RWSrc = _RWSrc;
	assign ALUSrcA = _ALUSrcA;
	assign ALUSrcB = _ALUSrcB;
	assign INSTR_FINISH = _INSTR_FINISH;
	assign ALUWrite = _ALUWrite;


    initial begin
		_Updated_uPC = 0;
        _RF_WE = 0;
        _ALUOp = 0;
        _D_MEM_WEN = 1;
        _D_MEM_BE = 0;
		_PCWrite = 0;
		_isBranch = 0;
		_MemRead = 0;
		_IorD = 0;
		_IRWrite = 0;
		_PCSrc = 0;
		_RWSrc = 0;
		_ALUSrcA = 0;
		_ALUSrcB = 0;
		_INSTR_FINISH = 0;
		_ALUWrite  =0;
    end
    always @ (*) begin
		case (uPC)
			3'b000 : // IF
			begin
				_Updated_uPC = uPC + 1;
				_RF_WE = 0;
			//	_ALUOp = 0;
			//	_D_MEM_WEN = 1;
			//	_D_MEM_BE = 0;
			//	_isBranch = 0;
				_MemRead = 1; // read i_mem 
				_IorD = 0;
				_IRWrite = 0;
			//	_PCSrc = 0;
			//	_RWSrc = 0;
			//	_ALUSrcA = 0;
			//	_ALUSrcB = 0;
				if (_INSTR_FINISH == 1) _PCWrite = 1;
				_ALUWrite  =0;
			end
			3'b001 : // ID
			begin
				_Updated_uPC = uPC + 1;
				_RF_WE = 0;
				_ALUOp = 0;
				_D_MEM_WEN = 1;
				_D_MEM_BE = 0;
				_PCWrite = 0;
				_isBranch = 0;
				_MemRead = 0;
				_IorD = 0;
				_IRWrite = 1; // ID
				_PCSrc = 0;
				_RWSrc = 0;
				_ALUSrcA = 0;
				_ALUSrcB = 0;
				_INSTR_FINISH = 0;
				_ALUWrite  =0;
			end
			3'b010 : // EX
			begin
				_RF_WE = 0;
				_ALUOp = 0; // default: Add
				_D_MEM_WEN = 1;
				_D_MEM_BE = 0;
				_PCWrite = 0;
				_isBranch = 0;
				_MemRead = 0;
				_IorD = 0;
				_IRWrite = 0;
				_PCSrc = 2'b00; // PC = PC + 4
				_RWSrc = 0;
				_ALUSrcA = 1; // 0: PC, 1: RA1
				_ALUSrcB = 1; // 0: RA2, 1: IMM
				_INSTR_FINISH = 0;
				_ALUWrite  = 1;
				case (INSTR[6:0])
					7'b1101111 : // JAL
					begin
						_ALUSrcA = 0;
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
						case(INSTR[14:12])
							3'b000: _ALUOp = 4'b1001; //BEQ
							3'b001: _ALUOp = 4'b1010; //BNE
							3'b100: _ALUOp = 4'b1011; //BLT
							3'b101: _ALUOp = 4'b1100; //BGE
							3'b110: _ALUOp = 4'b1110; //BLTU
							3'b111: _ALUOp = 4'b1111; //BGEU
						endcase	
						_PCSrc = 2'b11; // PC depends on branch cond
						_isBranch = 1;
						_Updated_uPC = 0;
						_INSTR_FINISH = 1; // instruction end
					end
					7'b0000011 : // I Type Load LW
					begin
						_Updated_uPC = uPC + 1;
					end
					7'b0100011 : // SW
					begin
						_Updated_uPC = uPC + 1;
					end
					7'b0010011 : // I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
					begin
						_ALUOp[2:0] = INSTR[14:12];
						if (_ALUOp == 4'b0101 && INSTR[30]) _ALUOp[3] = 1;
						else _ALUOp[3] = 0;
						_Updated_uPC = uPC + 2;
					end
					7'b0110011 : // R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
					begin
						_ALUSrcB = 0;
						_ALUOp[2:0] = INSTR[14:12];
						if (INSTR[30]) _ALUOp[3] = 1;
						else _ALUOp[3] = 0;
						_Updated_uPC = uPC + 2;
					end
				endcase
			end
			3'b011 : // MEM
			begin
				_Updated_uPC = uPC + 1;
				_RF_WE = 0;
			//	_ALUOp = 0;
				_D_MEM_WEN = 1;
				_D_MEM_BE = 0;
				_PCWrite = 0;
				_isBranch = 0;
				_MemRead = 1; // read d_mem
				_IorD = 1;
				_IRWrite = 0;
			//	_PCSrc = 0;
				_RWSrc = 0;
			//	_ALUSrcA = 0;
			//	_ALUSrcB = 0;
				_INSTR_FINISH = 0;
				_ALUWrite  =0;
				if (INSTR[6:0] == 7'b0100011) begin //SW
					_D_MEM_WEN = 0;
					_D_MEM_BE = 4'b1111;
					_Updated_uPC = 0;
					_INSTR_FINISH = 1; // instruction end
				end
			end
			3'b100 : // WB
			begin
				_Updated_uPC = 0; // return to IF
				_RF_WE = 1;
			//	_ALUOp = 0;
				_D_MEM_WEN = 1;
			//	_D_MEM_BE = 0;
				_PCWrite = 0;
				_isBranch = 0;
			//	_MemRead = 0;
			//	_IorD = 0;
				_IRWrite = 0;
			//	_PCSrc = 0;
			//	_ALUSrcA = 0;
			//	_ALUSrcB = 0;
				_ALUWrite  =0;
				_INSTR_FINISH = 1; // instruction end
				// JAL and JALR
				if (INSTR[6:0] == 7'b1101111 || INSTR[6:0] == 7'b1100111) begin
					_RWSrc = 2'b00; // PC + 4
				end
				// LW
				else if (INSTR[6:0] ==7'b0000011)  begin
					_RWSrc = 2'b01; // D_MEM_DI
				end
				// I-type and R-type
				else begin
					_RWSrc = 2'b10; // ALU_RESULT
				end
			end
		endcase
    end
endmodule