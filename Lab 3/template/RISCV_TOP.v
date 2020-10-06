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


	reg [31:0] _RF_WD;
	assign RF_WD = _RF_WD;
	
	reg [31:0] INSTR;

	wire isItype, isLoad, isbranch, branch_con;
	wire [2:0] Lfunct;
	wire [3:0] OP, OP_branch;
	wire [11:0] TEMP_MEM_ADDR;
	wire [31:0] PC, ALUSRC, Updated_PC, BRANCH_PC, branch_out, IMM, IMM_EX, ALU_RESULT, DataToReg, ADD_PC, LOAD_DATA;

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
		if (isLoad) _RF_WD = DataToReg;
		if (~D_MEM_WEN) _RF_WD = ALU_RESULT;
		if (RF_WE) _RF_WD = ALU_RESULT;
		// for test
		/*
		INSTR = I_MEM_DI;
		$display(INSTR);
		$display("--------------------------------------------------------------------------------");
     	$display("Instruction: 0x%0h  IsStore: 0x%0h", INSTR, D_MEM_WEN);
    	$display("RF_RD1: 0x%0h, ALUSRC: 0x%0h, IMM: 0x%0h, IMM_EX: 0x%0h, ALU_RESULT: 0x%0h", RF_RD1, ALUSRC, IMM, IMM_EX, ALU_RESULT);
    	$display("PC: 0x%0h, Updated_PC: 0x%0h, NUM_INST: 0x%0h", PC, Updated_PC, NUM_INST);
    	$display("RF_WE: 0x%0h, isLoad: 0x%0h, RF_WD: 0x%0h, OUTPUT_PORT: 0x%0h", RF_WE, isLoad, RF_WD, OUTPUT_PORT);
		*/
	end

	CTRL control(
		.INSTR          (I_MEM_DI),
		.RF_RA1 		(RF_RA1),
		.RF_RA2			(RF_RA2),
		.RF_WA1			(RF_WA1),
		.OP				(OP),
		.OP_branch		(OP_branch),
		.isItype		(isItype),
		.isLoad			(isLoad),
		.isJump			(isJump),
		.isbranch		(isbranch),
		.Lfunct			(Lfunct),
		.RF_WE			(RF_WE),
		.IMM			(IMM),
		.D_MEM_WEN		(D_MEM_WEN),
		.D_MEM_BE		(D_MEM_BE)
	);

	SIGN_EXTEND imm_sign_extend(
		.IMM	(IMM),
		.IMM_EX	(IMM_EX)
	);

	MUX alusrc(
		.A	(RF_RD2),
		.B	(IMM_EX),
		.S	(isItype),
		.Out	(ALUSRC)
	);

	ALU alu(
		.A	(RF_RD1),
		.B	(ALUSRC),
		.OP		(OP),
		.Out (ALU_RESULT)
	);

	LOAD load(
		.SRC	(D_MEM_DI),
		.Lfunct	(Lfunct),
		.Out	(LOAD_DATA)
	);
	
	MUX memtoreg(
		.A	(ALU_RESULT),
		.B	(LOAD_DATA),
		.S	(isLoad),
		.Out	(DataToReg)
	);

	// SB, SH, SW
	TRANSLATE d_translate(
		.EFFECTIVE_ADDR          (ALU_RESULT),
		.instruction_type        (1'b0),
		.data_type   			 (1'b1),
		.MEM_ADDR         		 (D_MEM_ADDR)
	);

	ALU addpc(
		.A	(PC),
		.B	(32'h00000004),
		.OP	(4'h0),
		.Out (ADD_PC)
	);

	ALU branch_pc	(
		.A	(PC),
		.B	(IMM),
		.OP	(4'h0),
		.Out	(BRANCH_PC)
	);

	ALU branch_alu	(
		.A	(RF_RD1),
		.B	(RF_RD2),
		.OP	(OP_branch),
		.Out	(branch_out)
	);

	BRANCH_CON Branch_con	(
		.branch_out	(branch_out),
		.isbranch	(isbranch),
		.branch_con	(branch_con)

	);

	MUX branch(
		.A		(ADD_PC),
		.B		(BRANCH_PC),
		.S		(branch_con),
		.Out		(Updated_PC)
	);
	/*
	MUX jump(
		.A		(BRANCH_PC),
	//	.B		(JUMP),
	//	.S		(isJump),
		.B		(BRANCH_PC),
		.S		(1'b0),
		.Out	(Updated_PC)
	);
	*/
	HALT halt(
		.INSTR	(I_MEM_DI),
		.HALT	(HALT)	
	);
		
endmodule 