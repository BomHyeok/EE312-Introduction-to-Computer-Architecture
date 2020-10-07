module OUTPUT(
   input wire [31:0] _RF_WD,
   input wire isBranch,
   input wire isBranchTaken,
   output wire [31:0] OUTPUT_PORT
   );

   reg [31:0] _OUTPUT_PORT;
   assign OUTPUT_PORT = _OUTPUT_PORT;

   always @ (*) begin
      if (isBranch == 1 && isBranchTaken == 1) _OUTPUT_PORT = 32'h00000001;
      else if (isBranch == 1 && isBranchTaken == 0) _OUTPUT_PORT = 32'h00000000;
      else _OUTPUT_PORT = _RF_WD;
   end
endmodule