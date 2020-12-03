module CACHE (
	input wire CLK,
	input wire C_MEM_WEN,
	input wire C_MEM_CSN,
	input wire D_MemRead,
	input wire [11:0] C_MEM_ADDR,
	input wire [31:0] C_MEM_DI,
	input wire [31:0] D_MEM_DI,

	output wire D_MEM_WEN,
	output wire [11:0] D_MEM_ADDR,
	output wire [31:0] D_MEM_DOUT,
	output wire [31:0] C_MEM_DOUT,

	output wire STALL
	);
	
	integer i;
	reg [2:0] COUNTER, NEXT_COUNTER;
	reg [1:0] g;
	reg [1:0] BO;
	reg [2:0] IDX;
	reg [4:0] TAG;
	// 133 : V, 132~128 : TAG, 127~0 : DATA
	reg [133:0] CACHE [7:0];

	reg READ_MISS, WRITE_HIT, WRITE_MISS;
	// for count the num of hit or miss
	reg [31:0] r_hit, r_miss, w_hit, w_miss;

	reg _D_MEM_WEN;
	reg [11:0] _D_MEM_ADDR;
	reg [31:0] _C_MEM_DOUT, _D_MEM_DOUT;

	reg _STALL;

	assign D_MEM_WEN = _D_MEM_WEN;
	assign D_MEM_ADDR = _D_MEM_ADDR;
	assign D_MEM_DOUT = _D_MEM_DOUT;
	assign C_MEM_DOUT = _C_MEM_DOUT;

	assign STALL = _STALL;
	

	initial begin 
		COUNTER = 0;
		NEXT_COUNTER = 0;
		g = 0;
		BO = 0;
		IDX = 0;
		TAG = 0;

		READ_MISS = 0;
		WRITE_HIT = 0;
		WRITE_MISS = 0;

		r_hit = 0;
		r_miss = 0;
		w_hit = 0;
		w_miss = 0;

		_D_MEM_WEN = 0;
		_D_MEM_ADDR = 0;
		_D_MEM_DOUT = 0;
		_C_MEM_DOUT = 0;

		_STALL = 0;

		for (i = 0 ; i < 8 ; i = i + 1) begin
			CACHE[i] = 0;
		end
	end

	always @ (*) begin
		g = C_MEM_ADDR[1:0];
		BO = C_MEM_ADDR[3:2];
		IDX = C_MEM_ADDR[6:4];
		TAG = C_MEM_ADDR[11:7];
	end

	always @ (negedge CLK) begin
		if (~C_MEM_CSN && D_MemRead) begin
			COUNTER = NEXT_COUNTER;
			// 1st cycle
			if (COUNTER == 3'b000) begin
				if (C_MEM_WEN) begin
					// read-hit
					if (CACHE[IDX][132:128] == TAG && CACHE[IDX][133] == 1) begin
						r_hit = r_hit + 1;
						_D_MEM_WEN = 1;
						_D_MEM_ADDR = 0;
						_D_MEM_DOUT = 0;
						_STALL = 0;
						case (BO)
							2'b00 : _C_MEM_DOUT = CACHE[IDX][127:96];
							2'b01 : _C_MEM_DOUT = CACHE[IDX][95:64];
							2'b10 : _C_MEM_DOUT = CACHE[IDX][63:32];
							2'b11 : _C_MEM_DOUT = CACHE[IDX][31:0];
						endcase
					end
					else begin
						// read-miss
						r_miss = r_miss + 1;
						_D_MEM_ADDR = {TAG, IDX, 2'b00, g};
						//CACHE[IDX][127:96] = D_MEM_DI;
						CACHE[IDX][132:128] = TAG;
						CACHE[IDX][133] = 0;
						READ_MISS = 1;
						NEXT_COUNTER = 3'b001;
						_D_MEM_WEN = 1;
						_D_MEM_DOUT = 0;
						_C_MEM_DOUT = 0;
						_STALL = 1;
					end
				end
				
				if (~C_MEM_WEN) begin
					// write-hit
					if (CACHE[IDX][132:128] == TAG && CACHE[IDX][133] == 1) begin
						w_hit = w_hit + 1;
						WRITE_HIT = 1;
						CACHE[IDX][133] = 0;
						NEXT_COUNTER = 3'b001;
						_D_MEM_WEN = 1;
						_D_MEM_ADDR = 0;
						_D_MEM_DOUT = 0;
						_C_MEM_DOUT = 0;
						_STALL = 1;
					end
					// write-miss
					else begin
						w_miss = w_miss + 1;
						_D_MEM_ADDR = {TAG, IDX, 2'b00, g};
						//CACHE[IDX][127:96] = D_MEM_DI;
						CACHE[IDX][132:128] = TAG;
						CACHE[IDX][133] = 0;
						WRITE_MISS = 1;
						NEXT_COUNTER = 3'b001;
						_D_MEM_WEN = 1;
						_D_MEM_DOUT = 0;
						_C_MEM_DOUT = 0;
						_STALL = 1;
					end
				end 
			//	$display("read-hit: %d, read-miss: %d, write-hit: %d, write-miss: %d", r_hit, r_miss, w_hit, w_miss);
			end
			else begin
				case (COUNTER)
					// 2nd cycle
					3'b001 : begin
						if (READ_MISS || WRITE_MISS) begin
							_D_MEM_ADDR = {TAG, IDX, 2'b01, g};
							//CACHE[IDX][95:64] = D_MEM_DI;
							_D_MEM_WEN = 1;
							_D_MEM_DOUT = 0;
							_C_MEM_DOUT = 0;
							_STALL = 1;
						end
						else if (WRITE_HIT) begin
							_D_MEM_WEN = 1;
							_D_MEM_ADDR = 0;
							_D_MEM_DOUT = 0;
							_C_MEM_DOUT = 0;
							_STALL = 1;
							case (BO)
								2'b00 : CACHE[IDX][127:96] = C_MEM_DI;
								2'b01 : CACHE[IDX][95:64] = C_MEM_DI;
								2'b10 : CACHE[IDX][63:32] = C_MEM_DI;
								2'b11 : CACHE[IDX][31:0] = C_MEM_DI;
							endcase
						end
						else if (WRITE_MISS) begin
							_D_MEM_ADDR = {TAG, IDX, 2'b01, g};
							//CACHE[IDX][95:64] = D_MEM_DI;
							_D_MEM_WEN = 1;
							_D_MEM_DOUT = 0;
							_C_MEM_DOUT = 0;
							_STALL = 1;
						end
						_D_MEM_WEN = 1;
						_D_MEM_DOUT = 0;
						_C_MEM_DOUT = 0;
						_STALL = 1;
						NEXT_COUNTER = 3'b010;	
					end
					// 3rd cycle
					3'b010 : begin
						if (READ_MISS || WRITE_MISS) begin
							_D_MEM_ADDR = {TAG, IDX, 2'b10, g};
							//CACHE[IDX][63:32] = D_MEM_DI;
							_D_MEM_WEN = 1;
							_D_MEM_DOUT = 0;
						end
						else if (WRITE_HIT) begin
							_D_MEM_WEN = 0;
							_D_MEM_ADDR = C_MEM_ADDR;
							case (BO)
								2'b00 : _D_MEM_DOUT = CACHE[IDX][127:96];
								2'b01 : _D_MEM_DOUT = CACHE[IDX][95:64];
								2'b10 : _D_MEM_DOUT = CACHE[IDX][63:32];
								2'b11 : _D_MEM_DOUT = CACHE[IDX][31:0];
							endcase
							_C_MEM_DOUT = 0;
							_STALL = 1;
						end
						else if (WRITE_MISS) begin
							_D_MEM_ADDR = {TAG, IDX, 2'b10, g};
							//CACHE[IDX][63:32] = D_MEM_DI;
							_D_MEM_WEN = 1;
							_D_MEM_DOUT = 0;
							_C_MEM_DOUT = 0;
							_STALL = 1;
						end
						_C_MEM_DOUT = 0;
						_STALL = 1;
						NEXT_COUNTER = 3'b011;
					end
					// 4th cycle
					3'b011 : begin
						if (READ_MISS) begin
							_D_MEM_ADDR = {TAG, IDX, 2'b11, g};
							//CACHE[IDX][31:0] = D_MEM_DI;
							_D_MEM_WEN = 1;
							_D_MEM_DOUT = 0;
							_C_MEM_DOUT = 0;
							_STALL = 1;
						end
						else if (WRITE_HIT) begin
							_D_MEM_WEN = 1;
							_D_MEM_ADDR = 0;
							_D_MEM_DOUT = 0;
							_C_MEM_DOUT = 0;
							_STALL = 1;
						end
						else if (WRITE_MISS) begin
							_D_MEM_ADDR = {TAG, IDX, 2'b11, g};
							//CACHE[IDX][31:0] = D_MEM_DI;
							_D_MEM_WEN = 1;
							_D_MEM_DOUT = 0;
							_C_MEM_DOUT = 0;
							_STALL = 1;
						end
						else if (WRITE_HIT) _D_MEM_ADDR = 0;
						_D_MEM_WEN = 1;
						_D_MEM_DOUT = 0;
						_C_MEM_DOUT = 0;
						_STALL = 1;
						NEXT_COUNTER = 3'b100;
					end
					// 5th cycle
					3'b100 : begin
						_D_MEM_WEN = 1;
						_D_MEM_ADDR = 0;
						_D_MEM_DOUT = 0;
						_C_MEM_DOUT = 0;
						_STALL = 1;
						NEXT_COUNTER = 3'b101;
					end
					// 6th cycle
					3'b101 : begin
						_D_MEM_WEN = 1;
						_D_MEM_ADDR = 0;
						_D_MEM_DOUT = 0;
						_C_MEM_DOUT = 0;
						_STALL = 1;
						NEXT_COUNTER = 3'b110;
					end
					// 7th cycle
					3'b110 : begin
						if (READ_MISS) begin
							READ_MISS = 0;
							CACHE[IDX][133] = 1;
							_D_MEM_WEN = 1;
							_D_MEM_ADDR = 0;
							_D_MEM_DOUT = 0;
							_STALL = 0;
							case (BO)
								2'b00 : _C_MEM_DOUT = CACHE[IDX][127:96];
								2'b01 : _C_MEM_DOUT = CACHE[IDX][95:64];
								2'b10 : _C_MEM_DOUT = CACHE[IDX][63:32];
								2'b11 : _C_MEM_DOUT = CACHE[IDX][31:0];
							endcase
							NEXT_COUNTER = 3'b000;
						end
						else if (WRITE_HIT) begin
							WRITE_HIT = 0;
							CACHE[IDX][133] = 1;
							_D_MEM_WEN = 1;
							_D_MEM_ADDR = 0;
							_D_MEM_DOUT = 0;
							_C_MEM_DOUT = 0;
							_STALL = 0;
							NEXT_COUNTER = 3'b000;
						end
						else if (WRITE_MISS) begin
							WRITE_MISS = 0;
							WRITE_HIT = 1;
							_D_MEM_WEN = 1;
							_D_MEM_ADDR = 0;
							_D_MEM_DOUT = 0;
							_C_MEM_DOUT = 0;
							_STALL = 1;
							NEXT_COUNTER = 3'b001;
						end
					end
				endcase
			end
		end
	end

	always@ (posedge CLK) begin
		if (~C_MEM_CSN && D_MemRead) begin
			if (READ_MISS) begin
				case (COUNTER) 
					3'b000: CACHE[IDX][127:96] = D_MEM_DI;
					3'b001: CACHE[IDX][95:64] = D_MEM_DI;
					3'b010: CACHE[IDX][63:32] = D_MEM_DI;
					3'b011: CACHE[IDX][31:0] = D_MEM_DI;
				endcase
			end	
			if (WRITE_MISS) begin
				case (COUNTER) 
					3'b000: CACHE[IDX][127:96] = D_MEM_DI;
					3'b001: CACHE[IDX][95:64] = D_MEM_DI;
					3'b010: CACHE[IDX][63:32] = D_MEM_DI;
					3'b011: CACHE[IDX][31:0] = D_MEM_DI;
				endcase
			end	
		end
	end

endmodule
