`timescale 1ns/10ps
module SP_SRAM #(parameter ROMDATA = "", AWIDTH = 12, SIZE = 4096) (
	input	wire			CLK,
	input	wire			CSN,//chip select negative??
	input	wire	[AWIDTH-1:0]	ADDR,
	input	wire			WEN,//write enable negative??
	input	wire	[3:0]		BE,//byte enable
	input	wire	[31:0]		DI, //data in
	output	wire	[127:0]		DOUT // data out
);

	reg		[127:0]		outline;
	reg		[31:0]		ram[0 : SIZE-1];
	reg		[31:0]		temp;

	reg [11:0] ADDR_1;
	reg [11:0] ADDR_2;
	reg [11:0] ADDR_3;
	reg [11:0] ADDR_4;

	initial begin
		if (ROMDATA != "")
			$readmemh(ROMDATA, ram);
	end

	assign #1 DOUT = outline;

	always @ (negedge CLK) begin
		// Synchronous write
		if (~CSN)
		begin
			if (~WEN)
			begin
				temp = ram[ADDR];
				if (BE[0]) temp[7:0] = DI[7:0];
				if (BE[1]) temp[15:8] = DI[15:8];
				if (BE[2]) temp[23:16] = DI[23:16];
				if (BE[3]) temp[31:24] = DI[31:24];

				ram[ADDR] = temp;
			end
		end
	end

	always @ (*) begin
		// Asynchronous read
		if (~CSN)
		begin
			if (WEN) begin
				ADDR_1 = {ADDR[11:4], 2'b00, ADDR[1:0]};
				ADDR_2 = {ADDR[11:4], 2'b01, ADDR[1:0]};
				ADDR_3 = {ADDR[11:4], 2'b10, ADDR[1:0]};
				ADDR_4 = {ADDR[11:4], 2'b11, ADDR[1:0]};
				outline = {ram[ADDR_1], ram[ADDR_2], ram[ADDR_3], ram[ADDR_4]};
			end
		end
	end

endmodule
