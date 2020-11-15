module OUTPUT(
   input wire [31:0] RF_WD, ALUOUT, 
   input wire [1:0] OPSrc,
   input wire isBranch, Branch_Cond,
   output wire [31:0] OUTPUT_PORT
   );

   reg [31:0] _OUTPUT_PORT;
   assign OUTPUT_PORT = _OUTPUT_PORT;

   initial _OUTPUT_PORT = 0;

   always @ (*) begin
      case (OPSrc)
         2'b00 : _OUTPUT_PORT = RF_WD;    
         2'b01 : ALUOUT;               // SW
         2'b10 : // Branch
         begin  
            if (isBranch == 1 && Branch_Cond == 1) _OUTPUT_PORT = 32'h00000001;
            if (isBranch == 1 && Branch_Cond == 0) _OUTPUT_PORT = 32'h00000000;
         end
      endcase
   end
endmodule