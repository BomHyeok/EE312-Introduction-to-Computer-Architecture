module RISCV_TOP (
	//General Signals
	input wire CLK,
	input wire RSTn,

	//I-Memory Signals
	output wire I_MEM_CSN,
	input wire [31:0] I_MEM_DI,//input from IM
	output reg [11:0] I_MEM_ADDR,//in byte address

	//D-Memory Signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DI,
	output wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,

	//RegFile Signals
	output wire RF_WE,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA1,
	input wire [31:0] RF_RD1,
	input wire [31:0] RF_RD2,
	output wire [31:0] RF_WD,
	output wire HALT,                   // if set, terminate program
	// If get the instruction sequences 0x00c00093 0x00008067, HALT output wire should be set to 1
	output reg [31:0] NUM_INST,         // number of instruction completed
	output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
	);

	assign OUTPUT_PORT = RF_WD;

	initial begin
		NUM_INST <= 0;
	end

	// Only allow for NUM_INST
	always @ (negedge CLK) begin
		if (RSTn) NUM_INST <= NUM_INST + 1;
	end

	// TODO: implement
	// PC(D_MEM_ADDR??? idk), for HALT
	wire PRE_HALT;
	initial begin
		D_MEM_ADDR <= 0;
		PRE_HALT <= 0;
	end

	// does it cover also in sequentially same NUM_INST?
	always @ (NUM_INST) begin
		if (NUM_INST == 0x00c00093) begin
			PRE_HALT = 1;
		end 
		else begin
			PRE_HALT = 0;
		end
		if (PRE_HALT == 1 && NUM_INST == 0x00008067) begin
			PRE_HALT = 0;
			HALT = 1;
		end
		case (NUM_INST[6:0])
			// LUI
			// WHy do we have to write 7b' prefix?
			7b'0110111 :
			// AUIPC
			7b'0010111 :
			// JAL
			7b'1101111 :
			// JALR
			7b'1100111 :
			// B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
			7b'1100011 :
			// I Type Load (LB, LH, LW, LBU, LHU)
			7b'0000011 :
			// Store (SB, SH, SW)
			7b'0100011 :
			// I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
			7b'0010011 :
			// R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
			7b'0110011 :
			
	end
endmodule //
