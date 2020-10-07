module OUTPUT(
   input wire [31:0] ALU_RESULT, ADD_PC_IMM, ADD_PC, DataToReg, 
   input wire RF_WE, D_MEM_WEN, noRA1, isAUIPC, isJump, isBranch, isBranchTaken, isLoad, 
   output wire [31:0] RF_WD, OUTPUT_PORT
   );

   reg [31:0] _RF_WD, _OUTPUT_PORT;
   assign RF_WD = _RF_WD;
   assign OUTPUT_PORT = _OUTPUT_PORT;

   always @ (*) begin
      // LUI
		if (noRA1 && ~isJump && ~isAUIPC) _RF_WD = ALU_RESULT;
      // AUIPC
		if (isAUIPC) _RF_WD = ADD_PC_IMM;
      // jump
		if (isJump) _RF_WD = ADD_PC;
      // load
      if (isLoad) _RF_WD = DataToReg;
      // store and others
		if (~D_MEM_WEN || (RF_WE && ~isJump)) _RF_WD = ALU_RESULT;
      // branch
      if (isBranch == 1 && isBranchTaken == 1) _OUTPUT_PORT = 32'h00000001;
      else if (isBranch == 1 && isBranchTaken == 0) _OUTPUT_PORT = 32'h00000000;
      else _OUTPUT_PORT = _RF_WD;
   end
endmodule