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
   wire [31:0] PC, _IMM, IMM;
   wire [11:0] _I_MEM_ADDR;

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
      if (RSTn) NUM_INST <= NUM_INST + 1;
      /*
         _PC <= Updated_PC;
         _PRE_INSTR <= INSTR;
         */
   end

   TRANSLATE i_mem_read(
      .EFFECTIVE_ADDR         (PC),
      .i_mem_read            (1),
      .IorD               (0),
      .I_MEM_ADDR            (_I_MEM_ADDR)
   );

   always@ (*) begin
      I_MEM_ADDR = _I_MEM_ADDR;
      INSTR = I_MEM_DI;
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
    //   .Out    (Updated_PC)
      .Out    (ADD_PC)
   );

   ID id(
      .IRWrite   (1),
      .INSTR      (INSTR),
      .RF_RA1      (RF_RA1),
      .RF_RA2      (RF_RA2),
      .RF_WA1      (WA_IFID),
      .IMM      (IMM)
   );

   pipeCTRL controller(
      
   );

   PR_IDEX pr_idex(

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
		.ForwardB      (ForwardB),
   );

   MUX_ALU mux_ALUSrcA(
		.A				(PC),	// should change
		.B				(RF_RD1_OUT),
		.ALUOUT_EXMEM	(ALUOUT_EXMEM),
		.ADD_PC			(ADD_PC_EXMEM),
		.RF_WD			(RF_WD),
		.Forward		(ForwardA),
		.S				(ALUSrcA),
		.isJump			(isJump),
		.Out			(ALU_A)
   );

   MUX_ALU mux_ALUSrcB(
		.A				(RF_RD2_OUT),
		.B				(IMM_OUT),
		.ALUOUT_EXMEM	(ALUOUT_EXMEM),
		.ADD_PC			(ADD_PC_EXMEM),
		.RF_WD			(RF_WD),
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
		.D_MEM_BE_IDEX		(D_MEM_BE_IDEX),
		.D_MEM_WEN_IDEX		(D_MEM_WEN_IDEX),
		.D_MemRead_IDEX		(D_MemRead_IDEX),
		.D_MEM_BE 			(D_MEM_BE),
		.D_MEM_WEN			(D_MEM_WEN),
		.D_MemRead			(D_MemRead),
		.RWSrc_IDEX			(RWSrc_IDEX),
		.RF_WE_IDEX			(RF_WE_IDEX),
		.RWSrc_EXMEM		(RWSrc_EXMEM),
		.RF_WE_EXMEM		(RF_WE_EXMEM),
		.ALU_RESULT 		(ALU_RESULT),
		.ADD_PC_IDEX		(ADD_PC_IDEX),
		.WA_IDEX			(WA_IDEX),
		.ALUOUT_EXMEM		(ALUOUT_EXMEM),
		.ADD_PC_EXMEM		(ADD_PC_EXMEM),
		.WA_EXMEM			(WA_EXMEM)
	);

	TRANSLATE d_mem_read(
		.EFFECTIVE_ADDR          (ALUOUT_EXMEM),
		.MemRead				 (D_MemRead),
		.IorD     				 (1),
		.MEM_ADDR         		 (D_MEM_ADDR)
	);

	PR_MEMWB pr_memwb(
		.RWSrc_EXMEM		(RWSrc_EXMEM),
		.RF_WE_EXMEM		(RF_WE_EXMEM),
		.RWSrc 				(RWSrc),
		.RF_WE				(RF_WE),
		.ALUOUT_EXMEM		(ALUOUT_EXMEM),
		.ADD_PC_EXMEM		(ADD_PC_EXMEM),
		.D_MEM_DI			(D_MEM_DI),
		.WA_EXMEM			(WA_EXMEM),
		.ALUOUT_MEMWB		(ALUOUT_MEMWB),
		.ADD_PC_MEMWB		(ADD_PC_MEMWB),
		.D_MEM_DI_OUT		(D_MEM_DI_OUT),
		.WA_MEMWB			(WA_MEMWB)
	);

	RWSRC rwsrc(
		.ADD_PC			(ADD_PC_MEMWB),
		.D_MEM_DI		(D_MEM_DI_OUT),
		.ALU_RESULT		(ALUOUT_MEMWB),
		.RWSrc			(RWSrc),
		.RF_WE			(RF_WE),
		.RF_WD			(RF_WD)
	);

endmodule 
