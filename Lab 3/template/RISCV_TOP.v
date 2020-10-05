module RISCV_TOP (
	//General Signals
	input wire CLK,
	input wire RSTn,

	//I-Memory Signals
	output wire I_MEM_CSN,
	input wire [31:0] I_MEM_DI,//input from IM
	output reg [11:0] I_MEM_ADDR,//in byte address

	//D-Memory Signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DI,
	output wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,

	//RegFile Signals
	output wire RF_WE,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA1,
	input wire [31:0] RF_RD1,
	input wire [31:0] RF_RD2,
	output wire [31:0] RF_WD,
	output wire HALT,                   // if set, terminate program
	// If get the instruction sequences 0x00c00093 0x00008067, HALT output wire should be set to 1
	output reg [31:0] NUM_INST,         // number of instruction completed
	output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
	);

	assign OUTPUT_PORT = RF_WD;

	initial begin
		NUM_INST <= 0;
	end

	// Only allow for NUM_INST
	always @ (negedge CLK) begin
		if (RSTn) NUM_INST <= NUM_INST + 1;
	end

	// TODO: implement
	
	
	reg PRE_HALT, _HALT, _RF_WE, INSTR_TYPE;
	// INSTR_TYPE = {R, I} 이런식으로 DEFINE 같은 게 있으면 더 좋을듯
	reg [31:0] INSTR, IMM, PC, _RF_RA1, _RF_RA2, _RF_WD, Target, EFFECTIVE_ADDR, _ALUSRC;
	reg [4:0] _RF_WA;
	reg [3:0] OP;
	wire [11:0] TEMP_MEM_ADDR;
	wire [31:0] ALUSRC;

	assign HALT = _HALT;
	assign RF_WE = _RF_WE;
	assign RF_WD = _RF_WD;
	assign RF_WA = _RF_WA;
	assign RF_RA1 = _RF_RA1;
	assign RF_RA2 = _RF_RA2;
	assign ALUSRC = _ALUSRC;
	
	initial begin
		PC <= 0;
		PRE_HALT = 0;
	end

	TRANSLATE i_translate(
		.EFFECTIVE_ADDR          (PC),
		.instruction_type        (1'b1),
		.data_type   			 (1'b0),
		.MEM_ADDR         		 (TEMP_MEM_ADDR)
	);
/*
	TRANSLATE d_translate(
		.EFFECTIVE_ADDR          (EFFECTIVE_ADDR),
		.instruction_type        (0),
		.data_type   			 (1),
		.MEM_ADDR         		 (MEM_ADDR)
	);
*/

	CTRL control(
		.INSTR          (INSTR),
		.PC        		(PC),
		.RF_RA1 		(RF_RA1),
		.RF_RA2			(RF_RA2),
		.RF_WD			(RF_WD),
		.ALUSRC			(ALUSRC),
		.RF_RD1			(RF_RD1),
		.RF_WA1			(RF_WA1),
		.OP				(OP),
		.INSTR_TYPE		(INSTR_TYPE),
		.OUTPUT_PORT	(OUTPUT_PORT)
	);

	MUX alusrc(
		.A	(RF_RD1),
		.B	(IMM),
		.S	(INSTR_TYPE),
		.Out	(ALUSRC)
	);

	ALU alu(
		.A	(ALUSRC),
		.B	(RF_RD2),
		.OP	(OP),
		.C	(RF_WD)
	);

	always@ (*) begin
		I_MEM_ADDR = TEMP_MEM_ADDR;
		INSTR = I_MEM_DI;
		$display(INSTR);
	end

	always @ (negedge CLK) begin
		/*
		if (RSTn == 1) begin
			assign I_MEM_CSN = 0;
			assign D_MEM_CSN = 0;
		end
		else begin
			I_MEM_CSN = 1;
			D_MEM_CSN = 1;
		end
		*/
	end

	// does it cover also in sequentially same NUM_INST?
	always @ (INSTR) begin
		/*
		if (INSTR == 32'h00c00093) begin
			PRE_HALT = 1;
		end 
		else begin
			PRE_HALT = 0;
		end
		if (PRE_HALT == 1 && INSTR == 32'h00008067) begin
			PRE_HALT = 0;
			_HALT = 1;
		end
		*/
		
	end
endmodule //
