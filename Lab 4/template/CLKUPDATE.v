module CLKUPDATE(
    input wire [2:0] Updated_A,
    input wire CLK,
    input wire RSTn,
    output wire [2:0] A
    );

    reg [2:0] TEMP;
    assign A = TEMP;
    initial	TEMP = 0;

    always @ (posedge CLK) begin
      if (~RSTn) TEMP = 0;
      else TEMP = Updated_A;
	  end

endmodule