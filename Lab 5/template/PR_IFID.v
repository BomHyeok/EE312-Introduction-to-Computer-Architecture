module PR_IFID(
	input wire CLK,
	input wire RSTn,
	input wire [31:0] PC, ADD_PC, INSTR,
	
	output wire [31:0] PC_IFID, ADD_PC_IFID, INSTR_IFID
);
	
	reg [31:0] PC_TEMP, ADD_PC_TEMP, INSTR_TEMP;
	reg [4:0] RF_WA1_TEMP, RF_RA1_TEMP, RF_RA2_TEMP;

	assign PC_IDEX = PC_TEMP;
	assign ADD_PC_IDEX = ADD_PC_TEMP;
	assign INSTR_IFID = INSTR_TEMP;

	initial begin
		PC_TEMP = 0;
		ADD_PC_TEMP = 0;
		INSTR_TEMP = 0;
	end

	always @ (posedge CLK) begin
		if (RSTn) begin
			PC_TEMP = PC;
			ADD_PC_TEMP = ADD_PC;
			INSTR_TEMP = INSTR;
		end
	end
		

endmodule
