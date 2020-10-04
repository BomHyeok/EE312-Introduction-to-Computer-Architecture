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
	
	// PC, for HALT
	wire PRE_HALT;
	wire [31:00] IMM;
	initial begin
		PC <= 0;
		PRE_HALT <= 0;
	end

	always @ (negedge CLK) begin
		if (RSTn == 1) begin
			I_MEM_CSN <= 0;
			D_MEM_CSN <= 0;
		end
		else begin
			I_MEM_CSN <= 1;
			D_MEM_CSN <= 1;
		end
	end

	// does it cover also in sequentially same NUM_INST?
	always @ (INSTR) begin
		if (INSTR == 0x00c00093) begin
			PRE_HALT = 1;
		end 
		else begin
			PRE_HALT = 0;
		end
		if (PRE_HALT == 1 && INSTR == 0x00008067) begin
			PRE_HALT = 0;
			HALT = 1;
		end
		case (INSTR[6:0])
			// LUI
			// WHy do we have to write 7b' prefix?
			7b'0110111 :
				IMM[31:12] = INSTR[31:12];
				IMM[11:0] = 0;
				RF_WA = INSTR[11:7];
				RF_WE = 1;
				RF_WD = IMM;
			// AUIPC
			7b'0010111 :
				IMM[31:12] = INSTR[31:12];
				IMM[11:0] = 0;
				RF_WA = INSTR[11:7];

				
			// JAL
			7b'1101111 :
				IMM[20:0] = {INSTR[31], INSTR[19:12], INSTR[20], INSTR[30:21]};
				RF_WA = INSTR[11:7];
				Target = PC + IMM;
				RF_WD = PC + 4;
				PC = Target;
			// JALR
			7b'1100111 :
				IMM[11:0] = INSTR[31:20];
				RF_RA1 = INSTR[19:15];
				RF_WA = INSTR[11:7];
				Target = (RF_RD1 + IMM) & 0xfffffffe;
				RF_WD = PC + 4;
				PC = Target;
			// B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
			7b'1100011 :
				IMM[12:0] = {INSTR[31], INSTR[7], INSTR[30:25], INSTR[11:8]};
				RF_RA1 = INSTR[19:15];
				RF_RA2 = INSTR[24:20];
				OP = INSTR[14:12];

			// I Type Load (LB, LH, LW, LBU, LHU)
			7b'0000011 :
				IMM[11:0] = INSTR[31:20];
				RF_WA = INSTR[11:7];
				Effective_address = IMM + RF_RD1;
				WD = MEM[translate(Effective_address)];
				PC = PC + 4;
			// Store (SB, SH, SW)
			7b'0100011 :
				IMM[11:5] = INSTR[31:25];
				IMM[4:0] = INSTR[11:7];

			// I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
			7b'0010011 :
				IMM[11:0] = INSTR[31:20];
				RF_RA1 = INSTR[19:15];
				RF_WE = 1;
				RF_WA = INSTR[11:7];
				OP = INSTR[14:12];
				ALU(IMM, RF_RD2, OP, RF_WD);
			// R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
			7b'0110011 :
				RF_RA1 = INSTR[19:15];
				RF_RA2 = INSTR[24:20];
				RF_WE = 1;
				RF_WA = INSTR[11:7];
				OP = INSTR[14:12];
				ALU(RF_RD1, RF_RD2, OP, RF_WD);
			default: WD = 0;
		endcase
	end
endmodule //
