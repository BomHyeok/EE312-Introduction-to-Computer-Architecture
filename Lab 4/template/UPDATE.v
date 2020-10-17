module UPDATE(
    input wire [31:0] Updated_A,
    input wire Update_Sign,
    output wire [31:0] A
    );

    reg [31:0] TEMP;
    assign A = TEMP;
    initial	TEMP = 0;

    always @ (*) begin
		  if (Update_Sign) TEMP = Updated_A;
      else TEMP = 0;
	  end

endmodule