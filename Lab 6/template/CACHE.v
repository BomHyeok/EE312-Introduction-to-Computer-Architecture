module CACHE (
	input wire CLK,
	input wire C_MEM_WEN,
	input wire C_MEM_CSN,
//	input wire C_MEM_READ,
	input wire D_MemRead,
	input wire [11:1] C_MEM_ADDR,
	input wire [31:0] C_MEM_DI,
	input wire [31:0] D_MEM_DOUT,

//	output wire D_MemRead,
	output wire D_MEM_WEN,
	output wire [11:0] D_MEM_ADDR,
	output wire [31:0] C_MEM_DOUT,

	output wire STALL
	);
	
	integer i;
	reg [2:0] COUNTER, NEXT_COUNTER;
	reg [1:0] BO;
	reg [2:0] IDX;
	reg [4:0] TAG;
	// 133 : V, 132~128 : TAG, 127~0 : DATA
	reg [133:0] CACHE [7:0];

	reg READ_MISS, WRITE_HIT, WRITE_MISS;

	reg _D_MemRead, _D_MEM_WEN;
	reg [11:0] _D_MEM_ADDR;
	reg [31:0] _C_MEM_DOUT;

	reg _STALL;

	assign D_MemRead = _D_MemRead;
	assign D_MEM_WEN = _D_MEM_WEN;
//	assign D_MEM_ADDR = C_MEM_ADDR;
	assign D_MEM_ADDR = _D_MEM_ADDR;
	assign C_MEM_DOUT = _C_MEM_DOUT;

	assign STALL = _STALL;
	


	initial begin 
		COUNTER = 0;
		NEXT_COUNTER = 0;
		BO = 0;
		IDX = 0;
		TAG = 0;

		READ_MISS = 0;
		WRITE_HIT = 0;
		WRITE_MISS = 0;

	//	_D_MemRead = 0;
		_D_MEM_WEN = 0;
		_D_MEM_ADDR = 0;
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
	//	if (~C_MEM_CSN && C_MEM_READ) begin
		if (~C_MEM_CSN && D_MemRead) begin
			COUNTER = NEXT_COUNTER;
			// 1st cycle
			if (COUNTER == 3'b000) begin
				if (C_MEM_WEN) begin
					// read-hit
					if (CACHE[IDX][132:128] == TAG && CACHE[IDX][133] == 1) begin
						case (BO)
							2'b00 : _C_MEM_DOUT = CACHE[IDX][127:96];
							2'b01 : _C_MEM_DOUT = CACHE[IDX][95:64];
							2'b10 : _C_MEM_DOUT = CACHE[IDX][63:32];
							2'b11 : _C_MEM_DOUT = CACHE[IDX][31:0];
						endcase
					end
					else begin
						// read-miss
						READ_MISS = 1;
						CACHE[IDX][133] = 0;
					//	D_MemRead = 1;
						_D_MEM_ADDR = C_MEM_ADDR;
						NEXT_COUNTER = 3'b001;
						_STALL = 1;
					end
				end
				
				if (~C_MEM_WEN) begin
					// write-hit
					if (CACHE[IDX][132:128] == TAG && CACHE[IDX][133] == 1) begin
						NEXT_COUNTER = 3'b001;
						CACHE[IDX][133] = 0;
						_STALL = 1;
						_D_MEM_WEN = 0;
						WRITE_HIT = 1;
						case (BO)
							2'b00 : CACHE[IDX][127:96] = C_MEM_DI;
							2'b01 : CACHE[IDX][95:64] = C_MEM_DI;
							2'b10 : CACHE[IDX][63:32] = C_MEM_DI;
							2'b11 : CACHE[IDX][31:0] = C_MEM_DI;
						endcase
					end
					// write-miss
					else begin
						WRITE_MISS = 1;
						CACHE[IDX][133] = 0;
					//	D_MemRead = 1;
						_D_MEM_ADDR = C_MEM_ADDR;
						NEXT_COUNTER = 3'b001;
						_STALL = 1;
					end
				end 
				
			end
			else begin
				case (COUNTER)
				// 2nd cycle
					3'b001 : begin
						if (READ_MISS) begin
							case (BO)
								3'b00 : CACHE[IDX][127:96] = D_MEM_DOUT;
								3'b01 : CACHE[IDX][95:64] = D_MEM_DOUT;
								3'b10 : CACHE[IDX][63:32] = D_MEM_DOUT;
								3'b11 : CACHE[IDX][31:0] = D_MEM_DOUT;
							endcase
							// _D_MemRead = 0;
							_D_MEM_ADDR = 0;
						end
						else if (WRITE_HIT) begin
							_D_MEM_WEN = 1;
						end
						else if (WRITE_MISS) begin
							
						end
						NEXT_COUNTER = 3'b010;	
					end
					// 3rd cycle
					3'b010 : begin
						NEXT_COUNTER = 3'b011;
					end
					// 4th cycle
					3'b011 : begin
						NEXT_COUNTER = 3'b100;
					end
					// 5th cycle
					3'b100 : begin
						NEXT_COUNTER = 3'b101;
					end
					// 6th cycle
					3'b101 : begin
						if (READ_MISS) begin
							CACHE[IDX][133] = 1;
							_STALL = 0;
							READ_MISS = 0;
							NEXT_COUNTER = 3'b000;
						end
						else if (WRITE_HIT) begin
							CACHE[IDX][133] = 1;
							_STALL = 0;
							WRITE_HIT = 0;
							NEXT_COUNTER = 3'b000;
						end
						else if (WRITE_MISS) begin
							NEXT_COUNTER = 3'b110;
						end
					end
					// 7th cycle
					3'b110 : begin
						NEXT_COUNTER = 3'b001;
					end
				endcase
			end
		end
	end

endmodule
