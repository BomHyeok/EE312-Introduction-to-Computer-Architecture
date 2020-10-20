module OUTPUT(
   input wire [31:0] RF_WD, ALU_RESULT,
   input wire isBranch, isBranchTaken, D_MEM_WEN, 
   output wire [31:0] OUTPUT_PORT
   );

   reg [31:0] _OUTPUT_PORT;
   assign OUTPUT_PORT = _OUTPUT_PORT;

   initial _OUTPUT_PORT = 0;

   always @ (*) begin
      // branch
      if (isBranch == 1 && isBranchTaken == 1) _OUTPUT_PORT = 32'h00000001;
      if (isBranch == 1 && isBranchTaken == 0) _OUTPUT_PORT = 32'h00000000;
      if (~D_MEM_WEN) _OUTPUT_PORT = ALU_RESULT;
      if (~isBranch && D_MEM_WEN) _OUTPUT_PORT = RF_WD;
   end
endmodule