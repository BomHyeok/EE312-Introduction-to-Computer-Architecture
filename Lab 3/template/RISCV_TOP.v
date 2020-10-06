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
	
	assign I_MEM_CSN = ~RSTn;
	assign D_MEM_CSN = ~RSTn;
	assign D_MEM_DOUT = RF_RD2;
	assign RF_WD = _RF_WD;
	
	reg PRE_HALT, _HALT, _RF_WE;
	// INSTR_TYPE = {R, I} 이런식으로 DEFINE 같은 게 있으면 더 좋을듯
	reg [31:0] INSTR, _RF_WD;
	// reg [31:0] INSTR, PC, _Updated_PC, _ALUSRC, _ALU_RESULT, _DataToReg, _RF_WD;
	// reg [3:0] _OP;
//	reg [2:0] _OP;
//	reg _isItype;
	wire isItype, isLoad;
	wire [2:0] OP;
	wire [11:0] TEMP_MEM_ADDR;
	wire [31:0] PC, ALUSRC, Updated_PC, IMM, IMM_EX, ALU_RESULT, DataToReg, ADD_PC, BRANCH_PC;

	assign HALT = _HALT;
//	assign ALUSRC = _ALUSRC;
//	assign Updated_PC = _Updated_PC;
//	assign DataToReg = _DataToReg;
//	assign ALU_RESULT = _ALU_RESULT;
//	assign isItype = _isItype;
//	assign OP = _OP;
	
	initial begin
		PRE_HALT = 0;
	end

	PC pc(
		.Updated_PC	(Updated_PC),
		.CLK	(CLK),
		.RSTn	(RSTn),
		.PC		(PC)
	);

	TRANSLATE i_translate(
		.EFFECTIVE_ADDR          (PC),
		.instruction_type        (1'b1),
		.data_type   			 (1'b0),
		.MEM_ADDR         		 (TEMP_MEM_ADDR)
	);
	
	always@ (*) begin
		I_MEM_ADDR = TEMP_MEM_ADDR;
		if (RF_WE) _RF_WD = DataToReg;
		// we may delete the following
		INSTR = I_MEM_DI;
		$display(INSTR);
	end

	CTRL control(
		.INSTR          (I_MEM_DI),
		.RF_RA1 		(RF_RA1),
		.RF_RA2			(RF_RA2),
		.RF_WA1			(RF_WA1),
		.OP				(OP),
		.isItype		(isItype),
		.isLoad			(isLoad),
		.isJump			(isJump),
		.RF_WE			(RF_WE),
		.RF_WD			(RF_WD),
		.IMM			(IMM),
		.D_MEM_WEN		(D_MEM_WEN),
		.D_MEM_BE		(D_MEM_BE)
	);

	ALU alu(
		.A	(RF_RD1),
		.B	(ALUSRC),
		.OP		(OP),
		.Out (ALU_RESULT)
	);

	SIGN_EXTENED imm_sign_extended(
		.IMM	(IMM),
		.IMM_EX	(IMM_EX)
	);

	MUX alusrc(
		.A	(RF_RD2),
		.B	(IMM_EX),
		.S	(isItype),
		.Out	(ALUSRC)
	);
	
	MUX memtoreg(
		.A	(ALU_RESULT),
		.B	(D_MEM_DI),
		.S	(isLoad),
		.Out	(DataToReg)
	);

	TRANSLATE d_translate(
		.EFFECTIVE_ADDR          (ALU_RESULT),
		.instruction_type        (1'b0),
		.data_type   			 (1'b1),
		.MEM_ADDR         		 (D_MEM_ADDR)
	);

	ALU addpc(
		.A	(PC),
		.B	(32'h00000004),
		.OP	(3'b000),
		.Out (ADD_PC)
	);

	MUX branch(
		.A		(ADD_PC),
	//	.B		(BRANCH),
	//	.S		(isBranchTaken),
		.B		(ADD_PC),
		.S		(1'b0),
		.Out	(BRANCH_PC)
	);

	MUX jump(
		.A		(BRANCH_PC),
	//	.B		(JUMP),
	//	.S		(isJump),
		.B		(BRANCH_PC),
		.S		(1'b0),
		.Out	(Updated_PC)
	);

	// does it cover also in sequentially same NUM_INST?
	always @ (INSTR) begin
		/*
		if (INSTR == 32'h00c00093) begin
			PRE_HALT = 1;
		end 
		else begin
			PRE_HALT = 0;
		end
		if (PRE_HALT == 1 && INSTR == 32'h00008067) begin
			PRE_HALT = 0;
			_HALT = 1;
		end
		*/
		
	end
endmodule //
