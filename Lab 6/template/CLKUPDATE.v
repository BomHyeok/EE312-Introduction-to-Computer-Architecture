module CLKUPDATE(
    input wire [31:0] Updated_A,
    input wire CLK,
    input wire RSTn,
    input wire STALL,
    output wire [31:0] A
    );

    reg [31:0] TEMP;
    assign A = TEMP;
    initial	TEMP = 0;

    always @ (posedge CLK) begin
      if (~RSTn) TEMP <= 0;
      else begin
        if (~STALL) TEMP <= Updated_A;
      end
	  end

endmodule