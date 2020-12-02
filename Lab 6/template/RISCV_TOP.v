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
	reg [31:0] INSTR, _PRE_INSTR;
	wire [31:0] PRE_INSTR, INSTR_IFID, PC, PC_IFID, PC_IDEX, Updated_PC, ALUOUT_PC, ADD_PC, ADD_PC_IFID, ADD_PC_IDEX, ADD_PC_EXMEM, ADD_PC_MEMWB;
	wire [31:0] IMM, IMM_OUT, RF_RD1_OUT, RF_RD2_OUT, RF_RD2_IDEX, RF_RD2_EXMEM, Branch_A, Branch_B;
	wire [31:0] ALUOUT_EXMEM, ALUOUT_MEMWB, ALU_A, ALU_B, ALU_RESULT, C_MEM_DI_OUT, C_MEM_DOUT, C_MEM_DI;
	wire [11:0] _I_MEM_ADDR, C_MEM_ADDR;
	wire [4:0] RF_RA1_OUT, RF_RA2_OUT, WA_IFID, WA_IDEX, WA_EXMEM, WA_MEMWB;
	wire [3:0] ALUOp_IFID, D_MEM_BE_IFID, D_MEM_BE_IDEX, ALUOp;
	wire [1:0] RWSrc_IFID, RWSrc_IDEX, RWSrc_EXMEM, ForwardA, ForwardB, BranchForwardA, BranchForwardB, SWForwardB;
	wire [1:0] RWSrc, OPSrc_IFID, OPSrc_IDEX, OPSrc_EXMEM, OPSrc, PCSrc_IFID, PCSrc_IDEX, PCSrc_EXMEM, PCSrc_MEMWB;
	wire ALUSrcA_IFID, ALUSrcB_IFID, ALUSrcA, ALUSrcB, D_MEM_WEN_IFID, D_MEM_WEN_IDEX, C_MEM_WEN;
	wire D_MemRead_IFID, D_MemRead_IDEX, D_MemRead, RF_WE_IFID, RF_WE_IDEX, RF_WE_EXMEM;
	wire Branch_Cond, Branch_Cond_EXMEM, Branch_Cond_MEMWB, isLoad_IFID, isJump_IFID, isLoad, isJump;
	wire NUM_CHECK_IFID, NUM_CHECK_IDEX, NUM_CHECK_EXMEM, NUM_CHECK, HALT_IFID, HALT_IDEX, HALT_EXMEM;
	wire Hazard_Sig, FLUSH_IFID, FLUSH_IDEX, FLUSH_EXMEM, STALL;

	assign I_MEM_CSN = ~RSTn;
  	assign D_MEM_CSN = ~RSTn;
   	assign C_MEM_DOUT = RF_RD2_EXMEM;

   initial begin
      NUM_INST <= 0;
      I_MEM_ADDR = 0;
      INSTR = 0;
      _PRE_INSTR = 0;
   end

   assign PRE_INSTR = _PRE_INSTR;
   assign RF_WA1 = WA_MEMWB;  // check later

   // Only allow for NUM_INST
   always @ (posedge CLK) begin
		if (RSTn) begin
        	_PRE_INSTR <= INSTR_IFID;
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
	  //$display("--------------------------------------------------------------------------------");
     	//$display("INSTR: 0x%0h PRE_INSTR: 0x%0h , NUM_INST: 0x%0h", INSTR, PRE_INSTR, NUM_INST);
    	//$display("RF_RD1: 0x%0h, ALUSrcA: 0x%0h, ALUSrcB: 0x%0h, IMM: 0x%0h, ALUOp: 0x%0h, ALU_RESULT: 0x%0h", RF_RD1, ALUSrcA, ALUSrcB, IMM, ALUOp, ALU_RESULT);
    	//$display("PC: 0x%0h, ADD_PC: 0x%0h, Updated_PC: 0x%0h, NUM_INST: 0x%0h", PC, ADD_PC, Updated_PC, NUM_INST);
	//	$display("uPC: 0x%0h, Updated_uPC: 0x%0h, PCWrite: 0x%0h, PCUpdate: 0x%0h", uPC, Updated_uPC, PCWrite, PCUpdate);
	//	$display("isBranch: 0x%0h, isBranchTaken: 0x%0h", isBranch, isBranchTaken);
		//$display("RF_WE: 0x%0h, RWSrc: 0x%0h, RF_WD: 0x%0h, OUTPUT_PORT: 0x%0h", RF_WE, RWSrc, RF_WD, OUTPUT_PORT);
		//$display("NUM_CHECK_IFID: 0x%0h, NUM_CHECK_IDEX: 0x%0h, NUM_CHECK_EXMEM: 0x%0h, NUM_CHECK: 0x%0h", NUM_CHECK_IFID, NUM_CHECK_IDEX, NUM_CHECK_EXMEM, NUM_CHECK);
            //$display("--------------------------------------------------------------------------------");
  // $display("INSTR: 0x%0h PRE_INSTR: 0x%0h , NUM_INST: 0x%0h", INSTR, PRE_INSTR, NUM_INST);
   //$display("RF_RD1: 0x%0h, ALUSrcA: 0x%0h, ALUSrcB: 0x%0h, IMM: 0x%0h, ALUOp: 0x%0h, ALU_RESULT: 0x%0h", RF_RD1, ALUSrcA, ALUSrcB, IMM, ALUOp, ALU_RESULT);
   //$display("PC: 0x%0h, ADD_PC: 0x%0h, Updated_PC: 0x%0h, ALUOUT_PC: 0x%0h", PC, ADD_PC, Updated_PC, ALUOUT_PC);
//   $display("RF_WE: 0x%0h, RWSrc: 0x%0h, RF_WD: 0x%0h, OUTPUT_PORT: 0x%0h", RF_WE, RWSrc, RF_WD, OUTPUT_PORT);
   //$display("D_MEM_DI: 0x%0h, D_MEM_DI_OUT: 0x%0h", D_MEM_DI,D_MEM_DI_OUT);
//   $display("RF_RA1: 0x%0h, RF_RA1_OUT: 0x%0h, RF_RA2: 0x%0h, RF_RA2_OUT: 0x%0h", RF_RA1, RF_RA1_OUT, RF_RA2, RF_RA2_OUT);
//   $display("ForwardA: 0x%0h, ALUSrcA: 0x%0h, ALU_A: 0x%0h, a", ForwardA, ALUSrcA, ALU_A);
//   $display("ForwardB: 0x%0h, ALUSrcB: 0x%0h, ALU_B: 0x%0h", ForwardB, ALUSrcB, ALU_B);
//	$display("ALUOp_IFID: 0x%0h, ALUOp: 0x%0h", ALUOp_IFID, ALUOp);
//   $display("ALU_RESULT: 0x%0h, ALUOUT_EXMEM: 0x%0h, ALUOUT_MEMWB: 0x%0h", ALU_RESULT, ALUOUT_EXMEM, ALUOUT_MEMWB);
//   $display("PCSrc_IFID: 0x%0h, PCSrc_IDEX: 0x%0h, PCSrc_EXMEM: 0x%0h, PCSrc_MEMWB: 0x%0h", PCSrc_IFID, PCSrc_IDEX, PCSrc_EXMEM, PCSrc_MEMWB);
//   $display("RF_RD1: 0x%0h, RF_RD1_OUT: 0x%0h, RF_RD2: 0x%0h, RF_RD2_OUT: 0x%0h", RF_RD1, RF_RD1_OUT, RF_RD2, RF_RD2_OUT);
//   $display("RF_WE_IFID: 0x%0h, RF_WE_IDEX: 0x%0h, RF_WE_EXMEM: 0x%0h, RF_WE: 0x%0h", RF_WE_IFID, RF_WE_IDEX, RF_WE_EXMEM, RF_WE);
//   $display("WA_IFID: 0x%0h, WA_IDEX: 0x%0h, WA_EXMEM: 0x%0h, WA_MEMWB: 0x%0h", WA_IFID, WA_IDEX, WA_EXMEM, WA_MEMWB);
   //$display("D_MemRead_IFID: 0x%0h, D_MemRead_IDEX: 0x%0h, D_MemRead: 0x%0h, D_MEM_ADDR: 0x%0h", D_MemRead_IFID, D_MemRead_IDEX, D_MemRead, D_MEM_ADDR);
   //$display("D_MEM_WEN: 0x%0h, D_MEM_BE: 0x%0h, D_MEM_DOUT: 0x%0h", D_MEM_WEN, D_MEM_BE, D_MEM_DOUT);
//   $display("OPSrc_IFID: 0x%0h, OPSrc_IDEX: 0x%0h, OPSrc_EXMEM: 0x%0h, OPSrc: 0x%0h", OPSrc_IFID, OPSrc_IDEX, OPSrc_EXMEM, OPSrc);
//	$display("Branch_Cond: 0x%0h, Branch_Cond_EXMEM: 0x%0h, Branch_Cond_MEMWB: 0x%0h", Branch_Cond, Branch_Cond_EXMEM, Branch_Cond_MEMWB);
//	$display("Branch_A: 0x%0h, Branch_B: 0x%0h, BranchForwardA: 0x%0h, BranchForwardB: 0x%0h", Branch_A, Branch_B, BranchForwardA, BranchForwardB);

	end

   CLKUPDATE pc(
      .Updated_A      (Updated_PC),
      .CLK         (CLK), 
      .RSTn         (RSTn),
      .A            (PC)
   );

   ADDER add_pc(
      .A      (PC),
      .B      (32'h00000004),
      .Out    (ADD_PC)
   );

	HAZARD_DETECT hazard_detection_unit(
		.PCSrc			(PCSrc_EXMEM),
		.Branch_Cond	(Branch_Cond_EXMEM),
		.ALUOUT_EXMEM	(ALUOUT_EXMEM),
		.ALUOUT_PC		(ALUOUT_PC),
		.Hazard_Sig		(Hazard_Sig),
		.FLUSH_IFID		(FLUSH_IFID),
		.FLUSH_IDEX		(FLUSH_IDEX),
		.FLUSH_EXMEM	(FLUSH_EXMEM)
	);

	MUX pc_mux(
		.A		(ADD_PC),
		.B		(ALUOUT_PC),
		.S		(Hazard_Sig),
		.Out	(Updated_PC)
	);

	PR_IFID pr_ifid(
		//input
		.CLK		(CLK),
		.RSTn		(RSTn),
		.FLUSH_IFID	(FLUSH_IFID),
		.STALL		(STALL),
		.PC		(PC),
		.ADD_PC		(ADD_PC),
		.INSTR		(INSTR),
		//output
		.PC_IFID	(PC_IFID),
		.ADD_PC_IFID	(ADD_PC_IFID),
		.INSTR_IFID	(INSTR_IFID)
	);

   ID id(
      .IRWrite   (1'b1),
      .INSTR      (INSTR_IFID),
      .RF_RA1      (RF_RA1),
      .RF_RA2      (RF_RA2),
      .RF_WA1      (WA_IFID),
      .IMM      (IMM)
   );

	pipeCTRL controller(
		.INSTR      	(INSTR_IFID),
		.ALUOp_IFID	(ALUOp_IFID),
		.ALUSrcA_IFID	(ALUSrcA_IFID),
		.ALUSrcB_IFID	(ALUSrcB_IFID),
		.isJump_IFID	(isJump_IFID),
		.isLoad_IFID	(isLoad_IFID),
		.D_MEM_BE_IFID	(D_MEM_BE_IFID),
		.D_MEM_WEN_IFID	(D_MEM_WEN_IFID),
		.D_MemRead_IFID	(D_MemRead_IFID),
		.PCSrc_IFID	(PCSrc_IFID),
		.RWSrc_IFID	(RWSrc_IFID),
		.OPSrc_IFID	(OPSrc_IFID),
		.RF_WE_IFID	(RF_WE_IFID),
		.NUM_CHECK_IFID	(NUM_CHECK_IFID)
   );
	
	HALT halt(
		.INSTR		(INSTR_IFID), //I_MEM_DI ??
		.PRE_INSTR	(PRE_INSTR),		.HALT		(HALT_IFID)	
	);

	PR_IDEX pr_idex(
		//input
		.CLK		(CLK),
		.RSTn		(RSTn),
		.FLUSH_IDEX	(FLUSH_IDEX),
		.STALL		(STALL),
		.PC_IFID	(PC_IFID),
		.ADD_PC_IFID	(ADD_PC_IFID),
		.HALT_IFID	(HALT_IFID),
		.IMM		(IMM),
		.RF_RA1		(RF_RA1),
		.RF_RA2		(RF_RA2),
		.RF_WA1		(WA_IFID), // check the PR_IDEX module
		.RF_RD1		(RF_RD1),
		.RF_RD2		(RF_RD2),
		.ALUOp_IFID	(ALUOp_IFID),
		.ALUSrcA_IFID	(ALUSrcA_IFID),
		.ALUSrcB_IFID	(ALUSrcB_IFID),
		.D_MEM_BE_IFID	(D_MEM_BE_IFID),
		.D_MEM_WEN_IFID	(D_MEM_WEN_IFID),
		.D_MemRead_IFID	(D_MemRead_IFID),
		.PCSrc_IFID	(PCSrc_IFID),
		.isJump_IFID	(isJump_IFID),
		.isLoad_IFID	(isLoad_IFID),
		.RWSrc_IFID	(RWSrc_IFID),
		.OPSrc_IFID	(OPSrc_IFID),
		.RF_WE_IFID	(RF_WE_IFID),
		.NUM_CHECK_IFID	(NUM_CHECK_IFID),
		//output
		.PC_IDEX	(PC_IDEX),
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
		.D_MEM_BE_IDEX	(D_MEM_BE_IDEX),
		.D_MEM_WEN_IDEX	(D_MEM_WEN_IDEX),
		.D_MemRead_IDEX	(D_MemRead_IDEX),
		.PCSrc_IDEX	(PCSrc_IDEX),
		.isJump_IDEX	(isJump_IDEX),
		.isLoad_IDEX	(isLoad_IDEX),
		.RWSrc_IDEX	(RWSrc_IDEX),
		.OPSrc_IDEX	(OPSrc_IDEX),
		.RF_WE_IDEX	(RF_WE_IDEX),
		.NUM_CHECK_IDEX	(NUM_CHECK_IDEX)
	);

   FORWARD forwarding_unit(
		.RegWrite_EXMEM   	(RF_WE_EXMEM),
		.RegWrite_MEMWB   	(RF_WE),
		.isLoad     		(isLoad),
		.RF_RA1      		(RF_RA1_OUT),
		.RF_RA2      		(RF_RA2_OUT),
		.WA_EXMEM      		(WA_EXMEM),
		.WA_MEMWB      		(WA_MEMWB),
		.OPSrc_IDEX			(OPSrc_IDEX),
		.ALUSrcB			(ALUSrcB),
		.ForwardA      		(ForwardA),
		.ForwardB      		(ForwardB),
		.BranchForwardA     (BranchForwardA),
		.BranchForwardB     (BranchForwardB),
		.SWForwardB			(SWForwardB)
   );

   MUX_ALU mux_ALUSrcA(
		.A				(PC_IDEX),	// check later
		.B				(RF_RD1_OUT),
		.ALUOUT_EXMEM	(ALUOUT_EXMEM),
		.ADD_PC_EXMEM	(ADD_PC_EXMEM),
		.RF_WD			(RF_WD),
		.D_MEM_DI		(C_MEM_DI),
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
		.D_MEM_DI		(C_MEM_DI),
		.Forward		(ForwardB),
		.S				(ALUSrcB),
		.isJump			(isJump),
		.Out			(ALU_B)
   );

   MUX_ALU mux_BranchA(
	    .A				(PC_IDEX),	// check later
		.B				(RF_RD1_OUT),
		.ALUOUT_EXMEM	(ALUOUT_EXMEM),
		.ADD_PC_EXMEM	(ADD_PC_EXMEM),
		.RF_WD			(RF_WD),
		.D_MEM_DI		(C_MEM_DI),
		.Forward		(BranchForwardA),
		.S				(1'b1),
		.isJump			(isJump),
		.Out			(Branch_A)
   );
   
   MUX_ALU mux_BranchB(
	    .A				(RF_RD2_OUT),
		.B				(IMM_OUT),
		.ALUOUT_EXMEM	(ALUOUT_EXMEM),
		.ADD_PC_EXMEM	(ADD_PC_EXMEM),
		.RF_WD			(RF_WD),
		.D_MEM_DI		(C_MEM_DI),
		.Forward		(BranchForwardB),
		.S				(1'b0),
		.isJump			(isJump),
		.Out			(Branch_B)
   );

   MUX_ALU mux_SW_RD(
	    .A				(RF_RD2_OUT),
		.B				(IMM_OUT),
		.ALUOUT_EXMEM	(ALUOUT_EXMEM),
		.ADD_PC_EXMEM	(ADD_PC_EXMEM),
		.RF_WD			(RF_WD),
		.D_MEM_DI		(C_MEM_DI),
		.Forward		(SWForwardB),
		.S				(1'b0),
		.isJump			(isJump),
		.Out			(RF_RD2_IDEX)
   );

   ALU alu(
		.A				(ALU_A),
		.B				(ALU_B),
		.OP				(ALUOp),
		.Out 			(ALU_RESULT),
		.Branch_A		(Branch_A),
		.Branch_B		(Branch_B),
		.Branch_Cond	(Branch_Cond)
	);

	PR_EXMEM pr_exmem(
		.CLK		(CLK),
		.RSTn		(RSTn),
		.FLUSH_EXMEM	(FLUSH_EXMEM),
		.STALL		(STALL),
		.D_MEM_BE_IDEX		(D_MEM_BE_IDEX),
		.D_MEM_WEN_IDEX		(D_MEM_WEN_IDEX),
		.D_MemRead_IDEX		(D_MemRead_IDEX),
		.isJump_IDEX		(isJump_IDEX),
		.isLoad_IDEX		(isLoad_IDEX),
		.PCSrc_IDEX		(PCSrc_IDEX),
		.D_MEM_BE 			(D_MEM_BE),
		.D_MEM_WEN			(C_MEM_WEN),
		.D_MemRead			(D_MemRead),
		.isJump			(isJump),
		.isLoad			(isLoad),
		.PCSrc_EXMEM		(PCSrc_EXMEM),
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
		.RF_RD2_OUT			(RF_RD2_IDEX), 	//check later
		.WA_IDEX			(WA_IDEX),
		.HALT_IDEX			(HALT_IDEX),
		.Branch_Cond		(Branch_Cond),
		.ALUOUT_EXMEM		(ALUOUT_EXMEM),
		.ADD_PC_EXMEM		(ADD_PC_EXMEM),
		.RF_RD2_EXMEM		(RF_RD2_EXMEM),
		.WA_EXMEM			(WA_EXMEM),
		.HALT_EXMEM			(HALT_EXMEM),
		.Branch_Cond_EXMEM	(Branch_Cond_EXMEM)
	);

	TRANSLATE d_mem_read(
		.EFFECTIVE_ADDR          (ALUOUT_EXMEM),
		.MemRead				 (D_MemRead),
		.IorD     				 (1'b1),
		.MEM_ADDR         		 (C_MEM_ADDR)
	);

	CACHE data_cache(
		.CLK				(CLK),
		.C_MEM_WEN			(C_MEM_WEN),
		.C_MEM_CSN			(~RSTn),
		.D_MemRead			(D_MemRead),
		.C_MEM_ADDR			(C_MEM_ADDR),
		.C_MEM_DI			(C_MEM_DOUT),
		.C_MEM_DOUT			(C_MEM_DI),
	//	.D_MEM_DOUT			(D_MEM_DI or DOUT?), 
		.D_MEM_WEN			(D_MEM_WEN),
		.D_MEM_ADDR			(D_MEM_ADDR),
		.STALL				(STALL)
	);

	PR_MEMWB pr_memwb(
		.CLK		(CLK),
		.RSTn		(RSTn),
		.STALL		(STALL),
		.RWSrc_EXMEM		(RWSrc_EXMEM),
		.OPSrc_EXMEM		(OPSrc_EXMEM),
		.PCSrc_EXMEM		(PCSrc_EXMEM),
		.RF_WE_EXMEM		(RF_WE_EXMEM),
		.NUM_CHECK_EXMEM	(NUM_CHECK_EXMEM),
		.RWSrc 				(RWSrc),
		.OPSrc				(OPSrc),
		.PCSrc_MEMWB		(PCSrc_MEMWB),
		.RF_WE				(RF_WE),
		.NUM_CHECK			(NUM_CHECK),
		.ALUOUT_EXMEM		(ALUOUT_EXMEM),
		.ADD_PC_EXMEM		(ADD_PC_EXMEM),
		.D_MEM_DI			(C_MEM_DI),
		.WA_EXMEM			(WA_EXMEM),
		.HALT_EXMEM			(HALT_EXMEM),
		.Branch_Cond_EXMEM	(Branch_Cond_EXMEM),
		.ALUOUT_MEMWB		(ALUOUT_MEMWB),
		.ADD_PC_MEMWB		(ADD_PC_MEMWB),
		.D_MEM_DI_OUT		(C_MEM_DI_OUT),
		.WA_MEMWB			(WA_MEMWB),
		.HALT				(HALT),
		.Branch_Cond_MEMWB	(Branch_Cond_MEMWB)
	);

	always @ (posedge CLK) begin
		if (RSTn && NUM_CHECK_EXMEM) begin
			NUM_INST <= NUM_INST + 1;
		end
	end

	RWSRC rwsrc(
		.ADD_PC			(ADD_PC_MEMWB),
		.D_MEM_DI		(C_MEM_DI_OUT),
		.ALU_RESULT		(ALUOUT_MEMWB),
		.RWSrc			(RWSrc),
		.RF_WE			(RF_WE),
		.RF_WD			(RF_WD)
	);

	OUTPUT out(
		.RF_WD			(RF_WD),
		.ALUOUT			(ALUOUT_MEMWB),
		.OPSrc			(OPSrc),
		.PCSrc			(PCSrc_MEMWB),	
		.Branch_Cond	(Branch_Cond_MEMWB),
		.OUTPUT_PORT	(OUTPUT_PORT)
	);

endmodule 
