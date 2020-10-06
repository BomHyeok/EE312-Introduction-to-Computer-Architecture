module isJALR (
	input wire isjalr,
	input wire[31:0] ALU_RESULT,
	output wire[31:0] JALR_RESULT
	);

	reg[31:0] _JALR_RESULT;
	assign JALR_RESULT = _JALR_RESULT;

	always@ (*) begin
		if (isjalr == 0) _JALR_RESULT = ALU_RESULT;
		else if (isjalr == 1)  _JALR_RESULT = ALU_RESULT & 32'hfffffffe;
	end

endmodule
