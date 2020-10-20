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
	output wire HALT,
	output reg [31:0] NUM_INST,
	output wire [31:0] OUTPUT_PORT
	);

	// TODO: implement multi-cycle CPU
	assign I_MEM_CSN = ~RSTn;
	assign D_MEM_CSN = ~RSTn;
	

	reg [31:0] INSTR, _PRE_INSTR, _PC;
	wire [31:0] PC, Updated_PC, IMM, ADD_PC, PRE_INSTR, ALUSrcA_Out, ALUSrcB_Out, ALU_RESULT, ALU_OUT, Updated_RF_RD2;
	wire [11:0] _I_MEM_ADDR;
	wire [3:0] ALUOp;
	wire [2:0] uPC, Updated_uPC;
	wire [1:0] PCSrc, RWSrc;
	wire isBranch, isBranchTaken, PCWrite, MemRead, IorD, IRWrite, ALUSrcA, ALUSrcB, PCUpdate, NUM_INST_Update, ALUWrite;

	initial begin
		NUM_INST <= 0;
		I_MEM_ADDR = 0;
		INSTR = 0;
		_PC = 0;
		_PRE_INSTR = 0;
	end

	assign PC = _PC;
	assign PRE_INSTR = _PRE_INSTR;
	assign D_MEM_DOUT = Updated_RF_RD2;

	always @ (negedge CLK) begin
		if (RSTn && PCUpdate) begin
			NUM_INST <= NUM_INST + 1;
			_PC <= Updated_PC;
			_PRE_INSTR <= INSTR;
		end
	end

	always@ (*) begin
		I_MEM_ADDR = _I_MEM_ADDR;
		INSTR = I_MEM_DI;
	end

	CLKUPDATE upc(
		.Updated_A	(Updated_uPC),
		.CLK		(CLK),
		.RSTn		(RSTn),
		.A			(uPC)
	);

	uCTRL ucontroller(
		.INSTR          (I_MEM_DI),
		.uPC			(uPC),
		.ALUOp     		(ALUOp),
		.RF_WE          (RF_WE),
		.D_MEM_WEN		(D_MEM_WEN),
		.D_MEM_BE       (D_MEM_BE),
		.PCWrite     	(PCWrite),
		.isBranch       (isBranch),
		.MemRead        (MemRead),
		.IorD			(IorD),
		.IRWrite     	(IRWrite),
		.PCSrc			(PCSrc),
		.RWSrc			(RWSrc),
		.ALUSrcA        (ALUSrcA),
		.ALUSrcB        (ALUSrcB),
		.NUM_INST_Update (NUM_INST_Update),
		.ALUWrite		(ALUWrite),
		.Updated_uPC    (Updated_uPC)
	);
/*
	UPDATE pc(
		.Updated_A			(Updated_PC),
		.Update_Sign		(PCUpdate),
		.A					(PC)
	);
*/
	TRANSLATE i_mem_read(
		.EFFECTIVE_ADDR          (PC),
		.MemRead				 (MemRead),
		.IorD     				 (IorD),
		.MEM_ADDR         		 (_I_MEM_ADDR)
	);

	ID id(
		.IRWrite		(IRWrite),
		.INSTR			(I_MEM_DI),
		.RF_RA1 		(RF_RA1),
		.RF_RA2			(RF_RA2),
		.RF_WA1			(RF_WA1),
		.IMM			(IMM)
	);

	SIGN_EXTEND sign_extend(
		.IMM		(IMM),
		.IMM_EX		(IMM)
	);

	MUX mux_ALUSrcA(
		.A		(PC),
		.B		(RF_RD1),
		.S		(ALUSrcA),
		.Out	(ALUSrcA_Out)
	);

	MUX mux_ALUSrcB(
		.A		(RF_RD2),
		.B		(IMM),
		.S		(ALUSrcB),
		.Out	(ALUSrcB_Out)
	);

	ALU alu(
		.A				(ALUSrcA_Out),
		.B				(ALUSrcB_Out),
		.OP				(ALUOp),
		.Out 			(ALU_RESULT),
		.Branch_A		(RF_RD1),
		.Branch_B		(RF_RD2),
		.Branch_Cond	(Branch_Cond)
	);

	UPDATE aluout(
		.Updated_A		(ALU_RESULT),
		.Update_Sign	(ALUWrite),
		.A				(ALU_OUT)
	);

	TRANSLATE d_mem_read(
		.EFFECTIVE_ADDR          (ALU_OUT),
		.MemRead				 (MemRead),
		.IorD     				 (IorD),
		.MEM_ADDR         		 (D_MEM_ADDR)
	);

	ADDER add_pc(
		.A	(PC),
		.B	(32'h00000004),
		.Out (ADD_PC)
	);

	RWSRC rwsrc(
		.ADD_PC			(ADD_PC),
		.D_MEM_DI		(D_MEM_DI),
		.ALU_RESULT		(ALU_OUT),
		.RWSrc			(RWSrc),
		.RF_WE			(RF_WE),
		.RF_WD			(RF_WD)
	);

	AND branch_taken(
		.A		(Branch_Cond),
		.B		(isBranch),
		.Out	(isBranchTaken)
	);

	OR pcupdate(
		.A		(isBranchTaken),
		.B		(PCWrite),
		.Out	(PCUpdate)
	);

	PCSRC pcsrc(
		.ADD_PC			(ADD_PC),
		.ALU_RESULT		(ALU_OUT),
		.isBranchTaken	(isBranchTaken),
		.PCSrc			(PCSrc),
		.Updated_PC		(Updated_PC)
	);
/*
	UPDATE instr(
		.Updated_A		(INSTR),
		.Update_Sign	(PCUpdate),
		.A				(PRE_INSTR)
	);
*/
	OUTPUT out(
		.RF_WD			(RF_WD),
		.ALU_RESULT		(ALU_OUT),
		.isBranch		(isBranch),
		.isBranchTaken	(isBranchTaken),
		.D_MEM_WEN		(D_MEM_WEN),
		.OUTPUT_PORT	(OUTPUT_PORT)
	//	.OUTPUT_PORT	(Updated_OUTPUT_PORT)
   	);
/*
	UPDATE output_port(
		.Updated_A		(Updated_OUTPUT_PORT),
		.Update_Sign	(NUM_INST_Update),
		.A				(OUTPUT_PORT)
	);
*/
	HALT halt(
		.INSTR		(I_MEM_DI),
		.PRE_INSTR	(PRE_INSTR),
		.HALT		(HALT)	
	);

endmodule 
