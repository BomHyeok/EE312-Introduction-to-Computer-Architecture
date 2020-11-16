module pipeCTRL(
	input wire [31:0] INSTR,
	// EX
	output wire [3:0] ALUOp_IFID,
	output wire ALUSrcA_IFID, ALUSrcB_IFID, isJump_IFID, isLoad_IFID,
	// MEM
	output wire [3:0] D_MEM_BE_IFID,
	output wire D_MEM_WEN_IFID, D_MemRead_IFID,
	output wire [1:0] PCSrc_IFID,
	// WB
	output wire [1:0] RWSrc_IFID, OPSrc_IFID,
	output wire RF_WE_IFID, NUM_CHECK_IFID
	);

    reg [3:0] _ALUOp, _D_MEM_BE;
    reg [1:0] _RWSrc, _OPSrc, _PCSrc;
    reg _ALUSrcA, _ALUSrcB, _D_MEM_WEN, _D_MemRead, _RF_WE, _isJump, _isLoad, _NUM_CHECK;

    assign ALUOp_IFID = _ALUOp;
    assign ALUSrcA_IFID = _ALUSrcA;
	assign ALUSrcB_IFID = _ALUSrcB;
	assign isJump_IFID = _isJump;
	assign isLoad_IFID = _isLoad;
    assign D_MEM_BE_IFID = _D_MEM_BE;
    assign D_MEM_WEN_IFID = _D_MEM_WEN;
    assign D_MemRead_IFID = _D_MemRead;
	assign PCRrc_IFID = _PCSrc;
    assign RWSrc_IFID = _RWSrc;
	assign OPSrc_IFID = _OPSrc;
    assign RF_WE_IFID = _RF_WE;
	assign NUM_CHECK_IFID = _NUM_CHECK;

    initial begin
        _ALUOp = 0;
        _ALUSrcA = 0;
		_ALUSrcB = 0;
		_isJump = 0;
		_isLoad = 0;
        _D_MEM_BE = 0;
        _D_MEM_WEN = 1;
        _D_MemRead = 0;
		_PCSrc = 0;
        _RWSrc = 0;
		_OPSrc = 0;
        _RF_WE = 0;
		_NUM_CHECK = 0;
    end

	always@ (*) begin
		_NUM_CHECK = 0;
		case (INSTR[6:0])
			// JAL
			7'b1101111 :
			begin
				_ALUOp = 0;
				_ALUSrcA = 0;
				_ALUSrcB = 1;
				_isJump = 1;
				_isLoad = 0;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 0;
				_PCSrc = 2'b01;
				_RWSrc = 2'b00;
				_OPSrc = 2'b00;
				_RF_WE = 1;
				_NUM_CHECK = 1;
			end
			// JALR
			7'b1100111 :
			begin
				_ALUOp = 0;
				_ALUSrcA = 1;
				_ALUSrcB = 1;
				_isJump = 1;
				_isLoad = 0;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 0;
				_PCSrc = 2'b01;
				_RWSrc = 2'b00;
				_OPSrc = 2'b00;
				_RF_WE = 1;
				_NUM_CHECK = 1;
			end
			// B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
			7'b1100011 :
			begin
				case(INSTR[14:12])
					3'b000: _ALUOp = 4'b1001; //BEQ
					3'b001: _ALUOp = 4'b1010; //BNE
					3'b100: _ALUOp = 4'b1011; //BLT
					3'b101: _ALUOp = 4'b1100; //BGE
					3'b110: _ALUOp = 4'b1110; //BLTU
					3'b111: _ALUOp = 4'b1111; //BGEU
				endcase	
				_ALUSrcA = 0;
				_ALUSrcB = 1;
				_isJump = 0;
				_isLoad = 0;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 0;
				_PCSrc = 2'b11;
				_RWSrc = 2'b00;
				_OPSrc = 2'b10;
				_RF_WE = 0;
				_NUM_CHECK = 1;
			end
			// I Type Load LW
			7'b0000011 :
			begin
				_ALUOp = 0;
				_ALUSrcA = 1;
				_ALUSrcB = 1;
				_isJump = 0;
				_isLoad = 1;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 1;
				_PCSrc = 2'b00;
				_RWSrc = 2'b01;
				_OPSrc = 2'b00;
				_RF_WE = 1;
				_NUM_CHECK = 1;
			end
			// SW
			7'b0100011 :
			begin
				_ALUOp = 0;
				_ALUSrcA = 1;
				_ALUSrcB = 1;
				_isJump = 0;
				_isLoad = 0;
				_D_MEM_BE = 4'b1111;
				_D_MEM_WEN = 0;
				_D_MemRead = 1;
				_PCSrc = 2'b00;
				_RWSrc = 2'b00;
				_OPSrc = 2'b01;
				_RF_WE = 0;
				_NUM_CHECK = 1;
			end
			// I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
			7'b0010011 :
			begin
				_ALUOp[2:0] = INSTR[14:12];
				if (_ALUOp == 4'b0101 && INSTR[30]) _ALUOp[3] = 1;
				else _ALUOp[3] = 0;
				_ALUSrcA = 1;
				_ALUSrcB = 1;
				_isJump = 0;
				_isLoad = 0;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 0;
				_PCSrc = 2'b00;
				_RWSrc = 2'b10;
				_OPSrc = 2'b00;
				_RF_WE = 1;
				_NUM_CHECK = 1;
			end
			// R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
			7'b0110011 :
			begin
				_ALUOp[2:0] = INSTR[14:12];
				if (INSTR[30]) _ALUOp[3] = 1;
				else _ALUOp[3] = 0;
				_ALUSrcA = 1;
				_ALUSrcB = 0;
				_isJump = 0;
				_isLoad = 0;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 0;
				_PCSrc = 2'b00;
				_RWSrc = 2'b10;
				_OPSrc = 2'b00;
				_RF_WE = 1;
				_NUM_CHECK = 1;
			end
			default :
			begin
				_ALUOp = 0;
				_ALUSrcA = 0;
				_ALUSrcB = 0;
				_isJump = 0;
				_isLoad = 0;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 0;
				_PCSrc = 0;
				_RWSrc = 0;
				_OPSrc = 0;
				_RF_WE = 0;
				_NUM_CHECK = 0;
			end
		endcase
	end
endmodule