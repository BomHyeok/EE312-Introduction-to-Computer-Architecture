module pipeCTRL(
	input wire [31:0] INSTR,
	// EX
	output wire [3:0] ALUOp_IFID, 
	output wire ALUSrcA_IFID, ALUSrcB_IFID, isJump_IFID, isLoad_IFID,
	// MEM
	output wire [3:0] D_MEM_BE_IFID, 
	output wire D_MEM_WEN_IFID, D_MemRead_IFID,
	// WB
	output wire [1:0] RWSrc_IFID,
	output wire RF_WE_IFID
	);

    reg [3:0] _ALUOp, _D_MEM_BE;
    reg [1:0] _RWSrc;
    reg _ALUSrcA, _ALUSrcB, _D_MEM_WEN, _D_MemRead, _RF_WE, _isJump, _isLoad;

    assign ALUOp_IFID = _ALUOp;
    assign ALUSrcA_IFID = _ALUSrcA;
	assign ALUSrcB_IFID = _ALUSrcB;
	assign isJump_IFID = _isJump;
	assign isLoad_IFID = _isLoad;
    assign D_MEM_BE_IFID = _D_MEM_BE;
    assign D_MEM_WEN_IFID = _D_MEM_WEN;
    assign D_MemRead_IFID = _D_MemRead;
    assign RWSrc_IFID = _RWSrc;
    assign RF_WE_IFID = _RF_WE;

    initial begin
        _ALUOp = 0;
        _ALUSrcA = 0;
	_ALUSrcB = 0;
	_isJump = 0;
	_isLoad = 0;
        _D_MEM_BE = 0;
        _D_MEM_WEN = 1;
        _D_MemRead = 0;
        _RWSrc = 0;
        _RF_WE = 0;
    end

	always@ (*) begin
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
				_RWSrc = 2'b00;
				_RF_WE = 1;
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
				_RWSrc = 2'b00;
				_RF_WE = 1;
			end
			// B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
			7'b1100011 :
			begin
				_ALUOp = INSTR[14:12];
				_ALUSrcA = 0;
				_ALUSrcB = 1;
				_isJump = 0;
				_isLoad = 0;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 0;
				_RWSrc = 0;
				_RF_WE = 0;
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
				_RWSrc = 2'b01;
				_RF_WE = 1;
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
				_RWSrc = 0;
				_RF_WE = 0;
			end
			// I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
			7'b0010011 :
			begin
				_ALUOp = INSTR[14:12];
				_ALUSrcA = 1;
				_ALUSrcB = 1;
				_isJump = 0;
				_isLoad = 0;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 0;
				_RWSrc = 2'b10;
				_RF_WE = 1;
			end
			// R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
			7'b0110011 :
			begin
				_ALUOp = INSTR[14:12];
				_ALUSrcA = 1;
				_ALUSrcB = 0;
				_isJump = 0;
				_isLoad = 0;
				_D_MEM_BE = 0;
				_D_MEM_WEN = 1;
				_D_MemRead = 0;
				_RWSrc = 2'b10;
				_RF_WE = 1;
			end
		endcase
	end
endmodule