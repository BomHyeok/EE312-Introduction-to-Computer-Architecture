module PC(
    input wire [31:0] Updated_PC,
    input wire CLK,
    input wire RSTn,
    output wire [31:0] PC
    );

    reg [31:0] reg_PC;
    assign PC = reg_PC;
    
    initial begin
		reg_PC = 0;
	end

    always @ (negedge CLK) begin
		if (~RSTn) reg_PC = 0;
        else reg_PC = Updated_PC;
	end

endmodule