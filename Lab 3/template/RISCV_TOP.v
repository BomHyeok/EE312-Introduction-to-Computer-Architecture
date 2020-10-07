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
	initial I_MEM_ADDR = 0;
	
	reg [31:0] INSTR;

	wire noRA1, isItype, isAUIPC,isLoad, isJump, isJAL, isJALR, isBranch, isBranchTaken;
	wire [2:0] Lfunct;
	wire [3:0] OP;
	wire [11:0] TEMP_MEM_ADDR;
	wire [31:0] PC, ALUSRC1, ALUSRC2, Updated_PC, IMM, IMM_EX, ALU_RESULT, DataToReg, ADD_PC, BRANCH_PC, LOAD_DATA, Target_JUMP, Target_BRANCH, ADD_PC_IMM, PRE_INSTR;
	
	CLKUPDATE pc(
		.Updated_A	(Updated_PC),
		.CLK		(CLK),
		.RSTn		(RSTn),
		.A			(PC)
	);

	TRANSLATE i_translate(
		.EFFECTIVE_ADDR          (PC),
		.instruction_type        (1'b1),
		.data_type   			 (1'b0),
		.MEM_ADDR         		 (TEMP_MEM_ADDR)
	);
	
	always@ (*) begin
		I_MEM_ADDR = TEMP_MEM_ADDR;
		INSTR = I_MEM_DI;
		// for test
		/*
		INSTR = I_MEM_DI;
		$display("--------------------------------------------------------------------------------");
     	$display("Instruction: 0x%0h  IsStore: 0x%0h", INSTR, D_MEM_WEN);
    	$display("RF_RD1: 0x%0h, ALUSRC1: 0x%0h, IMM: 0x%0h, IMM_EX: 0x%0h, ALU_RESULT: 0x%0h", RF_RD1, ALUSRC1, IMM, IMM_EX, ALU_RESULT);
    	$display("PC: 0x%0h, Updated_PC: 0x%0h, NUM_INST: 0x%0h", PC, Updated_PC, NUM_INST);
    	$display("RF_WE: 0x%0h, isLoad: 0x%0h, RF_WD: 0x%0h, OUTPUT_PORT: 0x%0h", RF_WE, isLoad, RF_WD, OUTPUT_PORT);
		*/
	end

	OUTPUT out(
		.ALU_RESULT		(ALU_RESULT),
		.ADD_PC_IMM		(ADD_PC_IMM),
		.ADD_PC			(ADD_PC),
		.DataToReg		(DataToReg),
		.RF_WE			(RF_WE),
		.D_MEM_WEN		(D_MEM_WEN),
		.noRA1			(noRA1),
		.isAUIPC		(isAUIPC),
		.isJump			(isJump),
		.isLoad			(isLoad),
		.isBranch		(isBranch),
		.isBranchTaken	(isBranchTaken),
		.RF_WD			(RF_WD),
		.OUTPUT_PORT	(OUTPUT_PORT)
	);

	CTRL control(
		.INSTR          (I_MEM_DI),
		.RF_RA1 		(RF_RA1),
		.RF_RA2			(RF_RA2),
		.RF_WA1			(RF_WA1),
		.OP				(OP),
		.noRA1			(noRA1),
		.isItype		(isItype),
		.isAUIPC		(isAUIPC),
		.isLoad			(isLoad),
		.isJump			(isJump),
		.isJAL			(isJAL),
		.isJALR			(isJALR),
		.isBranch		(isBranch),
		.Lfunct			(Lfunct),
		.RF_WE			(RF_WE),
		.IMM			(IMM),
		.D_MEM_WEN		(D_MEM_WEN),
		.D_MEM_BE		(D_MEM_BE)
	);

	MUX alusrc1(
		.A	(RF_RD1),
		.B	(32'h00000000),
		.S	(noRA1),
		.Out	(ALUSRC1)
	);

	SIGN_EXTEND imm_sign_extend(
		.IMM	(IMM),
		.isJAL	(isJAL),
		.IMM_EX	(IMM_EX)
	);

	MUX alusrc2(
		.A	(RF_RD2),
		.B	(IMM_EX),
		.S	(isItype),
		.Out	(ALUSRC2)
	);

	ALU alu(
		.A	(ALUSRC1),
		.B	(ALUSRC2),
		.OP		(OP),
		.Out (ALU_RESULT)
	);

	// Load and Store 
	TRANSLATE d_translate(
		.EFFECTIVE_ADDR          (ALU_RESULT),
		.instruction_type        (1'b0),
		.data_type   			 (1'b1),
		.MEM_ADDR         		 (D_MEM_ADDR)
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

	ALU add_pc(
		.A	(PC),
		.B	(32'h00000004),
		.OP	(4'h0),
		.Out (ADD_PC)
	);

	ALU add_pc_imm(
		.A	(PC),
		.B	(ALU_RESULT),
		.OP	(4'h0),
		.Out (ADD_PC_IMM)
	);

	JUMP jump(
		.ADD_PC_IMM		(ADD_PC_IMM),
		.ALU_RESULT		(ALU_RESULT),
		.isJAL			(isJAL),
		.isJALR			(isJALR),
		.Target_JUMP	(Target_JUMP)
	);

	ALU branch_pc(
		.A	(PC),
		.B	(IMM),
		.OP	(4'h0),
		.Out	(Target_BRANCH)
	);
	
	AND Branch_taken(
		.A	(ALU_RESULT),
		.B	(isBranch),
		.Out	(isBranchTaken)
	);

	MUX mux_branch(
		.A		(ADD_PC),
		.B		(Target_BRANCH),
		.S		(isBranchTaken),
		.Out	(BRANCH_PC)
	);

	MUX mux_jump(
		.A		(BRANCH_PC),
		.B		(Target_JUMP),
		.S		(isJump),
		.Out	(Updated_PC)
	);
	
	CLKUPDATE instr(
		.Updated_A		(INSTR),
		.CLK			(CLK),
		.RSTn			(RSTn),
		.A				(PRE_INSTR)
	);

	HALT halt(
		.INSTR		(I_MEM_DI),
		.PRE_INSTR	(PRE_INSTR),
		.HALT		(HALT)	
	);
		
endmodule 
