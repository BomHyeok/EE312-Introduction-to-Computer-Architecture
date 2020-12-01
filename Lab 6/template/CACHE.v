module CACHE (
	input wire CLK,
	input wire C_MEM_WEN,
	input wire C_MEM_CSN,
	input wire [11:1] C_MEM_ADDR,
	input wire [31:0] C_MEM_DI,

	output wire D_MEM_WEN,
	output wire [31:0] D_MEM_ADDR,
	output wire [31:0] C_MEM_DOUT,

	output wire STALL
)
	
	integer i;
	reg [2:0] COUNT;
	reg [1:0] BO;
	reg [2:0] IDX;
	reg [4:0] TAG;
	// 133 : V, 132~128 : TAG, 127~0 : DATA
	reg [133:0] CACHE [7:0];

	reg WRITE_HIT;

	reg _D_MEM_WEN;
	reg [31:0] _C_MEM_DOUT;

	reg _STALL;

	assign D_MEM_WEN = _D_MEM_WEN;
	assign C_MEM_DOUT = _C_MEM_DOUT;

	assign STALL = _STALL;
	


	initial begin 
		COUNTER = 0;
		BO = 0;
		IDX = 0;
		TAG = 0;

		WRITE_HIT = 0;

		_D_MEM_WEN = 0;
		_C_MEM_DOUT = 0;

		_STALL = 0;

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
				if (CACHE[IDX][132:128] == TAG && CACHE[IDX][133] == 1) begin
					case (BO)
					3'b00 : begin
						_C_MEM_DOUT <= CACHE[127:96];
					end
					3'b01 : begin
						_C_MEM_DOUT <= CACHE[95:64];
					end
					3'b10 : begin
						_C_MEM_DOUT <= CACHE[63:32];
					end
					3'b11 : begin
						_C_MEM_DOUT <= CACHE[31:0];
					end
					endcase
				end
				// write-hit
				if (C_MEM_WEN == 0 && CACHE[IDX][132:128] == TAG && CACHE[IDX][133] == 1) begin
					_D_MEM_ADDR <= C_MEM_ADDR;
					COUNTER <= 3'b001;
					CACHE[IDX][133] <= 0;
					_STALL <= 1;
					_D_MEM_WEN <= 0;
					WRITE_HIT <= 1;
					case (BO)
					3'b00 : begin
						CACHE[127:96] <= C_mem_DI;
					end
					3'b01 : begin
						CACHE[95:64] <= C_mem_DI;
					end
					3'b10 : begin
						CACHE[63:32] <= C_mem_DI;
					end
					3'b11 : begin
						CACHE[31:0] <= C_mem_DI;
					end
					endcase
				end
			end
			else begin
				case (COUNTER)
				// 2nd cycle
				3'b001 : begin
					if (WRITE_HIT) begin
						COUNTER <= 3'b000;
						CACHE[IDX][133] <= 1;
						_STALL <= 0;
						_D_MEM_WEN <= 1;
						WRITE_HIT <= 0;
					end
						
					COUNTER <= 3'b010;
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
