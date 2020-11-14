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

   

   always@ () begin
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
      .Out    (Updated_PC)
      // .Out    (ADD_PC)
   );

   ID id(
      .IRWrite   (1)
      .INSTR      (INSTR)
      .RF_RA1      (RF_RA1)
      .RF_RA2      (RF_RA2)
      .RF_WA1      (RF_WA1)
      .IMM      (_IMM)
   );

   

   always@ () begin
      IMM = _IMM;
      WA_ID/EX = RF_WA1;
   end

   pipeCTRL controller(
      
   );

endmodule 
