module BRANCH_CON (
	input wire [31:0] branch_out,
	input wire isbranch,
	output wire branch_con
	);

	reg _branch_con;
	assign branch_con = _branch_con;

	always @ (*) begin
		if (branch_out[0] == 0 || isbranch == 0) _branch_con =0;
		else if (branch_out[0] == 1 && isbranch == 1) _branch_con=1;
	end
endmodule
