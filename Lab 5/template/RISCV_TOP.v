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
   output reg [31:0] NUM_INST,         // number of instruction completed
   output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
   );

//   assign OUTPUT_PORT = RF_WD;

   // TODO: implement
   assign I_MEM_CSN = ~RSTn;
   assign D_MEM_CSN = ~RSTn;
   // assign D_MEM_DOUT = RF_RD2;

	reg [31:0] INSTR, _PC, _PRE_INSTR;
	wire [31:0] PRE_INSTR, PC, Updated_PC, ADD_PC, ADD_PC_IDEX, ADD_PC_EXMEM, ADD_PC_MEMWB;
	wire [31:0] IMM, IMM_OUT, RF_RD1_OUT, RF_RD2_OUT;
	wire [31:0] ALUOUT_EXMEM, ALUOUT_MEMWB, ALU_A, ALU_B, ALU_RESULT, D_MEM_DI_OUT;
	wire [11:0] _I_MEM_ADDR;
	wire [4:0] RF_RA1_OUT, RF_RA2_OUT, WA_IFID, WA_IDEX, WA_EXMEM, WA_MEMWB;
	wire [3:0] ALUOp_IFID, D_MEM_BE_IFID, D_MEM_BE_IDEX, ALUOp;
	wire [1:0] RWSrc_IFID, RWSrc_IDEX, RWSrc_EXMEM, RWSrc, OPSrc_IFID, OPSrc_IDEX, OPSrc_EXMEM, OPSrc, ForwardA, ForwardB;
	wire ALUSrcA_IFID, ALUSrcB_IFID, ALUSrcA, ALUSrcB, D_MEM_WEN_IFID, D_MEM_WEN_IDEX;
	wire D_MemRead_IFID, D_MemRead_IDEX, D_MemRead, RF_WE_IFID, RF_WE_IDEX, RF_WE_EXMEM;
	wire RegWrite_EXMEM, RegWrite_MEMWB, Branch_Cond, isLoad_IFID, isJump_IFID, isLoad, isJump;
	wire NUM_CHECK_IFID, NUM_CHECK_IDEX, NUM_CHECK_EXMEM, NUM_CHECK, HALT_IFID, HALT_IDEX, HALT_EXMEM;

   initial begin
      NUM_INST <= 0;
      I_MEM_ADDR = 0;
      INSTR = 0;
      _PC = 0;
      _PRE_INSTR = 0;
   end

   assign PC = _PC;
   assign PRE_INSTR = _PRE_INSTR;
   assign RF_WA1 = WA_MEMWB;  // check later

   // Only allow for NUM_INST
   always @ (negedge CLK) begin
   //   if (RSTn) NUM_INST <= NUM_INST + 1;
		if (RSTn) begin
        	_PC <= Updated_PC;
        	_PRE_INSTR <= INSTR;
		end 
   end

   TRANSLATE i_mem_read(
      .EFFECTIVE_ADDR         (PC),
      .MemRead            (1'b1),
      .IorD               (1'b0),
      .MEM_ADDR            (_I_MEM_ADDR)
   );

   always@ (*) begin
      I_MEM_ADDR = _I_MEM_ADDR;
      INSTR = I_MEM_DI;
   end

   CLKUPDATE pc(
   //   .Updated_A      (Updated_PC),
	  .Updated_A      (ADD_PC),
      .CLK         (CLK),
      .RSTn         (RSTn),
      .A            (PC)
   );

   ADDER add_pc(
      .A      (PC),
      .B      (32'h00000004),
//      .Out    (Updated_PC)
      .Out    (ADD_PC)
   );

   ID id(
      .IRWrite   (1'b1),
      .INSTR      (INSTR),
      .RF_RA1      (RF_RA1),
      .RF_RA2      (RF_RA2),
      .RF_WA1      (WA_IFID),
      .IMM      (IMM)
   );

	pipeCTRL controller(
		.INSTR      	(INSTR),
		.ALUOp_IFID	(ALUOp_IFID),
		.ALUSrcA_IFID	(ALUSrcA_IFID),
		.ALUSrcB_IFID	(ALUSrcB_IFID),
		.isJump_IFID	(isJump_IFID),
		.isLoad_IFID	(isLoad_IFID),
		.D_MEM_BE_IFID	(D_MEM_BE_IFID),
		.D_MEM_WEN_IFID	(D_MEM_WEN_IFID),
		.D_MemRead_IFID	(D_MemRead_IFID),
		.RWSrc_IFID	(RWSrc_IFID),
		.OPSrc_IFID	(OPSrc_IFID),
		.RF_WE_IFID	(RF_WE_IFID),
		.NUM_CHECK_IFID	(NUM_CHECK_IFID)
   );
	
	HALT halt(
		.INSTR		(I_MEM_DI),
		.PRE_INSTR	(PRE_INSTR),
		.HALT		(HALT_IFID)	
	);

	PR_IDEX pr_idex(
		//input
		.CLK		(CLK),
		.RSTn		(RSTn),
		.ADD_PC		(ADD_PC),
		.HALT_IFID	(HALT_IFID),
		.IMM		(IMM),
		.RF_RA1		(RF_RA1),
		.RF_RA2		(RF_RA2),
		.RF_WA1		(RF_WA1),
		.RF_RD1		(RF_RD1),
		.RF_RD2		(RF_RD2),
		.ALUOp_IFID	(ALUOp_IFID),
		.ALUSrcA_IFID	(ALUSrcA_IFID),
		.ALUSrcB_IFID	(ALUSrcB_IFID),
		.isJump_IFID	(isJump_IFID),
		.isLoad_IFID	(isLoad_IFID),
		.D_MEM_BE_IFID	(D_MEM_BE_IFID),
		.D_MEM_WEN_IFID	(D_MEM_WEN_IFID),
		.D_MemRead_IFID	(D_MemRead_IFID),
		.RWSrc_IFID	(RWSrc_IFID),
		.OPSrc_IFID	(OPSrc_IFID),
		.RF_WE_IFID	(RF_WE_IFID),
		.NUM_CHECK_IFID	(NUM_CHECK_IFID),
		//output
		.ADD_PC_IDEX	(ADD_PC_IDEX),
		.HALT_IDEX	(HALT_IDEX),
		.IMM_OUT	(IMM_OUT),
		.RF_RA1_OUT	(RF_RA1_OUT),
		.RF_RA2_OUT	(RF_RA2_OUT),
		.WA_IDEX	(WA_IDEX),
		.RF_RD1_OUT	(RF_RD1_OUT),
		.RF_RD2_OUT	(RF_RD2_OUT),
		.ALUOp		(ALUOp),
		.ALUSrcA	(ALUSrcA),
		.ALUSrcB	(ALUSrcB),
		.isJump_IDEX	(isJump_IDEX),
		.isLoad_IDEX	(isLoad_IDEX),
		.D_MEM_BE_IDEX	(D_MEM_BE_IDEX),
		.D_MEM_WEN_IDEX	(D_MEM_WEN_IDEX),
		.D_MemRead_IDEX	(D_MemRead_IDEX),
		.RWSrc_IDEX	(RWSrc_IDEX),
		.OPSrc_IDEX	(OPSrc_IDEX),
		.RF_WE_IDEX	(RF_WE_IDEX),
		.NUM_CHECK_IDEX	(NUM_CHECK_IDEX)
	);

   FORWARD forwarding_unit(
		.RegWrite_EXMEM   (RegWrite_EXMEM),
		.RegWrite_MEMWB   (RegWrite_MEMWB),
		.isLoad     	 (isLoad),
		.RF_RA1      	(RF_RA1_OUT),
		.RF_RA2      	(RF_RA2_OUT),
		.WA_EXMEM      (WA_EXMEM),
		.WA_MEMWB      (WA_MEMWB),
		.ForwardA      (ForwardA),
		.ForwardB      (ForwardB)
   );

   MUX_ALU mux_ALUSrcA(
		.A				(PC),	// should change
		.B				(RF_RD1_OUT),
		.ALUOUT_EXMEM	(ALUOUT_EXMEM),
		.ADD_PC_EXMEM	(ADD_PC_EXMEM),
		.RF_WD			(RF_WD),
		.D_MEM_DI		(D_MEM_DI),
		.Forward		(ForwardA),
		.S				(ALUSrcA),
		.isJump			(isJump),
		.Out			(ALU_A)
   );

   MUX_ALU mux_ALUSrcB(
		.A				(RF_RD2_OUT),
		.B				(IMM_OUT),
		.ALUOUT_EXMEM	(ALUOUT_EXMEM),
		.ADD_PC_EXMEM	(ADD_PC_EXMEM),
		.RF_WD			(RF_WD),
		.D_MEM_DI		(D_MEM_DI),
		.Forward		(ForwardB),
		.S				(ALUSrcB),
		.isJump			(isJump),
		.Out			(ALU_B)
   );

   ALU alu(
		.A				(ALU_A),
		.B				(ALU_B),
		.OP				(ALUOp),
		.Out 			(ALU_RESULT),
		.Branch_A		(RF_RD1_OUT),
		.Branch_B		(RF_RD2_OUT),
		.Branch_Cond	(Branch_Cond)
	);

	PR_EXMEM pr_exmem(
		.CLK		(CLK),
		.RSTn		(RSTn),
		.D_MEM_BE_IDEX		(D_MEM_BE_IDEX),
		.D_MEM_WEN_IDEX		(D_MEM_WEN_IDEX),
		.D_MemRead_IDEX		(D_MemRead_IDEX),
		.isJump_IDEX		(isJump_IDEX),
		.isLoad_IDEX		(isLoad_IDEX),
		.D_MEM_BE 			(D_MEM_BE),
		.D_MEM_WEN			(D_MEM_WEN),
		.D_MemRead			(D_MemRead),
		.isJump			(isJump),
		.isLoad			(isLoad),
		.RWSrc_IDEX			(RWSrc_IDEX),
		.OPSrc_IDEX			(OPSrc_IDEX),
		.RF_WE_IDEX			(RF_WE_IDEX),
		.NUM_CHECK_IDEX		(NUM_CHECK_IDEX),
		.RWSrc_EXMEM		(RWSrc_EXMEM),
		.OPSrc_EXMEM		(OPSrc_EXMEM),
		.RF_WE_EXMEM		(RF_WE_EXMEM),
		.NUM_CHECK_EXMEM	(NUM_CHECK_EXMEM),
		.ALU_RESULT 		(ALU_RESULT),
		.ADD_PC_IDEX		(ADD_PC_IDEX),
		.WA_IDEX			(WA_IDEX),
		.HALT_IDEX			(HALT_IDEX),
		.Branch_Cond		(Branch_Cond),
		.ALUOUT_EXMEM		(ALUOUT_EXMEM),
		.ADD_PC_EXMEM		(ADD_PC_EXMEM),
		.WA_EXMEM			(WA_EXMEM),
		.HALT_EXMEM			(HALT_EXMEM),
		.Branch_Cond_EXMEM	(Branch_Cond_EXMEM)
	);

	TRANSLATE d_mem_read(
		.EFFECTIVE_ADDR          (ALUOUT_EXMEM),
		.MemRead				 (D_MemRead),
		.IorD     				 (1'b1),
		.MEM_ADDR         		 (D_MEM_ADDR)
	);

	PR_MEMWB pr_memwb(
		.CLK		(CLK),
		.RSTn		(RSTn),
		.RWSrc_EXMEM		(RWSrc_EXMEM),
		.OPSrc_EXMEM		(OPSrc_EXMEM),
		.RF_WE_EXMEM		(RF_WE_EXMEM),
		.NUM_CHECK_EXMEM	(NUM_CHECK_EXMEM),
		.RWSrc 				(RWSrc),
		.OPSrc				(OPSrc),
		.RF_WE				(RF_WE),
		.NUM_CHECK		(NUM_CHECK),
		.ALUOUT_EXMEM		(ALUOUT_EXMEM),
		.ADD_PC_EXMEM		(ADD_PC_EXMEM),
		.D_MEM_DI			(D_MEM_DI),
		.WA_EXMEM			(WA_EXMEM),
		.HALT_EXMEM			(HALT_EXMEM),
		.Branch_Cond_EXMEM	(Branch_Cond_EXMEM),
		.ALUOUT_MEMWB		(ALUOUT_MEMWB),
		.ADD_PC_MEMWB		(ADD_PC_MEMWB),
		.D_MEM_DI_OUT		(D_MEM_DI_OUT),
		.WA_MEMWB			(WA_MEMWB),
		.HALT				(HALT),
		.Branch_Cond_MEMWB	(Branch_Cond_MEMWB)
	);

	always @ (negedge CLK) begin
		if (RSTn && NUM_CHECK) begin
			NUM_INST <= NUM_INST + 1;
		end
	end

	RWSRC rwsrc(
		.ADD_PC			(ADD_PC_MEMWB),
		.D_MEM_DI		(D_MEM_DI_OUT),
		.ALU_RESULT		(ALUOUT_MEMWB),
		.RWSrc			(RWSrc),
		.RF_WE			(RF_WE),
		.RF_WD			(RF_WD)
	);

	OUTPUT out(
		.RF_WD			(RF_WD),
		.ALUOUT			(ALUOUT_MEMWB),
		.OPSrc			(OPSrc),
		// check later
	//	.isBranch		(isBranch_MEMWB),	
	//	.Branch_Cond	(Branch_Cond_MEMWB),
		.OUTPUT_PORT	(OUTPUT_PORT)
	);

endmodule 
