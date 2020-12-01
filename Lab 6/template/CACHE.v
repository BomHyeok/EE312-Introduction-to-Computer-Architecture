module CACHE (
	input wire CLK,
	input wire C_MEM_WEN,
	input wire C_MEM_CSN,
	input wire [11:1] C_MEM_ADDR,

	output wire [31:0] D_MEM_ADDR,
	output wire [31:0] C_MEM_DOUT
)
	
	integer i;
	reg [2:0] STATE;
	reg [1:0] BO;
	reg [2:0] IDX;
	reg [4:0] TAG;
	// 133 : V, 132~128 : TAG, 127~0 : DATA
	reg [133:0] CACHE [7:0];

	reg [31:0] _C_MEM_DOUT;

	assign C_MEM_DOUT = _C_MEM_DOUT;
	


	initial begin 
		COUNTER = 0;
		BO = 0;
		IDX = 0;
		TAG = 0;

		for (i = 0 ; i < 8 ; i++) begin
			CACHE[i] = 0;
		end
	end

	always @ (*) begin
		BO = C_MEM_ADDR[3:2];
		IDX = C_MEM_ADDR[6:4];
		TAG = C_MEM_ADDR[11:7];
	end

	always @ (posedge CLK) begin
		if (~C_MEM_CSN) begin
			// 1st cycle
			if (COUNTER = 3'b000) begin
				// read-hit
				if (CACHE[IDX][132:128] == TAG && CACHE[IDX] == 1) begin
					case (BO)
					3'b00 : begin
						_C_MEM_DOUT = CACHE[127:96];
					end
					3'b01 : begin
						_C_MEM_DOUT = CACHE[95:64];
					end
					3'b10 : begin
						_C_MEM_DOUT = CACHE[63:32];
					end
					3'b11 : begin
						_C_MEM_DOUT = CACHE[31:0];
					end
					endcase
				end
			end
			else begin
				case (COUNTER)
				// 2nd cycle
				3'b001 : begin
					COUNTER <= 3'd010;
				end
				// 3rd cycle
				3'b010 : begin
					COUNTER <= 3'b011;
				end
				// 4th cycle
				3'b011 : begin
					COUNTER <= 3'b100;
				end
				// 5th cycle
				3'b100 : begin
					COUNTER <= 3'b101;
				end
				// 6th cycle
				3'b101 : begin
					COUNTER <= 3'b000;
				end
				endcase
			end
		end
	end

endmodule
