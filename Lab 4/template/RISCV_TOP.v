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

	//test

	// TODO: implement multi-cycle CPU
	assign I_MEM_CSN = ~RSTn;
	assign D_MEM_CSN = ~RSTn;
	assign D_MEM_DOUT = RF_RD2;
	
	

	reg [31:0] INSTR, _PC, _PRE_INSTR;
	wire [31:0] PC, Updated_PC, IMM, ADD_PC, PRE_INSTR, ALUSrcA_Out, ALUSrcB_Out, ALU_RESULT, ALU_OUT;
	wire [11:0] _I_MEM_ADDR;
	wire [3:0] ALUOp;
	wire [2:0] uPC, Updated_uPC;
	wire [1:0] PCSrc, RWSrc;
	wire isBranch, isBranchTaken, PCWrite, MemRead, IorD, IRWrite, ALUSrcA, ALUSrcB, PCUpdate, INSTR_FINISH, ALUWrite;
	
	initial begin
		NUM_INST <= 0;
		I_MEM_ADDR = 0;
		INSTR = 0;
		_PC = 0;
		_PRE_INSTR = 0;
	end
	assign PC = _PC; 
	assign PRE_INSTR = _PRE_INSTR;

	always @ (negedge CLK) begin
		if (RSTn && PCUpdate && uPC == 0) begin
			NUM_INST <= NUM_INST + 1;
			_PC <= Updated_PC;
			_PRE_INSTR <= INSTR;
		end
	end

	always@ (*) begin
		I_MEM_ADDR = _I_MEM_ADDR;
		INSTR = I_MEM_DI;
/*
		$display("--------------------------------------------------------------------------------");
     	$display("INSTR: 0x%0h PRE_INSTR: 0x%0h , NUM_INST: 0x%0h", INSTR, PRE_INSTR, NUM_INST);
    	$display("RF_RD1: 0x%0h, ALUSrcA: (0x%0h) 0x%0h, ALUSrcB: (0x%0h) 0x%0h, IMM: 0x%0h, ALUOp: 0x%0h, ALU_RESULT: 0x%0h, ALU_OUT: 0x%0h", RF_RD1, ALUSrcA, ALUSrcA_Out, ALUSrcB, ALUSrcB_Out, IMM, ALUOp, ALU_RESULT, ALU_OUT);
    	$display("PC: 0x%0h, PCSrc: 0x%0h, ADD_PC: 0x%0h, Updated_PC: 0x%0h, NUM_INST: 0x%0h", PC, PCSrc, ADD_PC, Updated_PC, NUM_INST);
		$display("uPC: 0x%0h, Updated_uPC: 0x%0h, PCWrite: 0x%0h, PCUpdate: 0x%0h", uPC, Updated_uPC, PCWrite, PCUpdate);
		$display("isBranch: 0x%0h, isBranchTaken: 0x%0h", isBranch, isBranchTaken);
		$display("RF_WE: 0x%0h, RWSrc: 0x%0h, RF_WD: 0x%0h, OUTPUT_PORT: 0x%0h", RF_WE, RWSrc, RF_WD, OUTPUT_PORT);
*/
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
		.D_MEM_BE       (D_MEM_BE),
		.RF_WE          (RF_WE),
		.D_MEM_WEN		(D_MEM_WEN),
		.PCWrite     	(PCWrite),
		.isBranch       (isBranch),
		.MemRead        (MemRead),
		.IorD			(IorD),
		.IRWrite     	(IRWrite),
		.PCSrc			(PCSrc),
		.RWSrc			(RWSrc),
		.ALUSrcA        (ALUSrcA),
		.ALUSrcB        (ALUSrcB),
		.INSTR_FINISH 	(INSTR_FINISH),
		.ALUWrite		(ALUWrite),
		.Updated_uPC    (Updated_uPC)
	);

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
		.Updated_A	(ALU_RESULT),
		.Update_Sign	(ALUWrite),
		.A		(ALU_OUT)
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

	OUTPUT out(
		.RF_WD			(RF_WD),
		.ALU_RESULT			(ALU_OUT),
		.D_MEM_ADDR		(D_MEM_ADDR),	
		.isBranch		(isBranch),
		.isBranchTaken	(isBranchTaken),
		.D_MEM_WEN	(D_MEM_WEN),
		.OUTPUT_PORT	(OUTPUT_PORT)
  	);

	HALT halt(
		.INSTR		(I_MEM_DI),
		.PRE_INSTR	(PRE_INSTR),
		.HALT		(HALT)	
	);

endmodule 
