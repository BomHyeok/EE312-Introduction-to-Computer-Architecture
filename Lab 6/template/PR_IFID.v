module PR_IFID(
	input wire CLK,
	input wire RSTn,
	input wire FLUSH_IFID,
	input wire STALL,
	input wire [31:0] PC, ADD_PC, INSTR,
	
	output wire [31:0] PC_IFID, ADD_PC_IFID, INSTR_IFID
);
	
	reg [31:0] _PC_IFID, _ADD_PC_IFID, _INSTR_IFID;

	assign PC_IFID = _PC_IFID;
	assign ADD_PC_IFID = _ADD_PC_IFID;
	assign INSTR_IFID = _INSTR_IFID;

	initial begin
		_PC_IFID = 0;
		_ADD_PC_IFID = 0;
		_INSTR_IFID = 0;
	end

	always @ (posedge CLK) begin
		if (RSTn) begin
			if (~FLUSH_IFID && ~STALL) begin
				_PC_IFID <= PC;
				_ADD_PC_IFID <= ADD_PC;
				_INSTR_IFID <= INSTR;
			end
			if (FLUSH_IFID) begin
				_PC_IFID <= 0;
				_ADD_PC_IFID <= 0;
				_INSTR_IFID <= 0;
			end
		end
	end
		

endmodule
