module PR_IDEX(
	input wire CLK,
	input wire RSTn,
	input wire FLUSH_IDEX,
	input wire STALL,
	input wire [31:0] PC_IFID, ADD_PC_IFID,
	input wire HALT_IFID,
	// IMM & Register
	input wire [31:0] IMM,
	input wire [4:0] RF_RA1, RF_RA2, RF_WA1,
	input wire [31:0] RF_RD1, RF_RD2,
	// EX
	input wire [3:0] ALUOp_IFID, 
	input wire ALUSrcA_IFID, ALUSrcB_IFID,
	// MEM
	input wire [3:0] D_MEM_BE_IFID, 
	input wire D_MEM_WEN_IFID, D_MemRead_IFID,
	input wire [1:0] PCSrc_IFID,
	input wire isJump_IFID, isLoad_IFID,
	// WB
	input wire [1:0] RWSrc_IFID, OPSrc_IFID,
	input wire RF_WE_IFID, NUM_CHECK_IFID,
	
	output wire [31:0] PC_IDEX, ADD_PC_IDEX,
	output wire HALT_IDEX,
	// IMM & Register
	output wire [31:0] IMM_OUT,
	output wire [4:0] RF_RA1_OUT, RF_RA2_OUT, WA_IDEX,
	output wire [31:0] RF_RD1_OUT, RF_RD2_OUT,
	// EX
	output wire [3:0] ALUOp, 
	output wire ALUSrcA, ALUSrcB,
	// MEM
	output wire [3:0] D_MEM_BE_IDEX, 
	output wire D_MEM_WEN_IDEX, D_MemRead_IDEX,
	output wire [1:0] PCSrc_IDEX,
	output wire isJump_IDEX, isLoad_IDEX,
	// WB
	output wire [1:0] RWSrc_IDEX, OPSrc_IDEX,
	output wire RF_WE_IDEX, NUM_CHECK_IDEX
);
	
	reg [31:0] PC_TEMP, ADD_PC_TEMP, IMM_TEMP, RF_RD1_TEMP, RF_RD2_TEMP;
	reg [4:0] RF_WA1_TEMP, RF_RA1_TEMP, RF_RA2_TEMP;
	reg [3:0] ALUOp_TEMP, D_MEM_BE_TEMP;
	reg [1:0] RWSrc_TEMP, OPSrc_TEMP, PCSrc_TEMP;
	reg HALT_IDEX_TEMP, ALUSrcA_TEMP, ALUSrcB_TEMP, D_MEM_WEN_TEMP, D_MemRead_TEMP, RF_WE_TEMP, isJump_TEMP, isLoad_TEMP, NUM_CHECK_TEMP;

	assign PC_IDEX = PC_TEMP;
	assign ADD_PC_IDEX = ADD_PC_TEMP;
	assign HALT_IDEX = HALT_IDEX_TEMP;
	assign IMM_OUT = IMM_TEMP;
	assign RF_RA1_OUT = RF_RA1_TEMP;
 	assign RF_RA2_OUT = RF_RA2_TEMP;
	assign WA_IDEX = RF_WA1_TEMP;
	assign RF_RD1_OUT = RF_RD1_TEMP;
	assign RF_RD2_OUT = RF_RD2_TEMP;

	assign ALUOp = ALUOp_TEMP;
	assign ALUSrcA = ALUSrcA_TEMP;
	assign ALUSrcB = ALUSrcB_TEMP;

	assign D_MEM_BE_IDEX = D_MEM_BE_TEMP;
	assign D_MEM_WEN_IDEX = D_MEM_WEN_TEMP;
	assign D_MemRead_IDEX = D_MemRead_TEMP;
	assign PCSrc_IDEX = PCSrc_TEMP;
	assign isJump_IDEX = isJump_TEMP;
	assign isLoad_IDEX = isLoad_TEMP;
	
	assign RWSrc_IDEX = RWSrc_TEMP;
	assign OPSrc_IDEX = OPSrc_TEMP;
	assign RF_WE_IDEX = RF_WE_TEMP;
	assign NUM_CHECK_IDEX = NUM_CHECK_TEMP;

	initial begin
		PC_TEMP = 0;
		ADD_PC_TEMP = 0;
		HALT_IDEX_TEMP = 0;
		IMM_TEMP = 0;
		RF_RA1_TEMP = 0;
 		RF_RA2_TEMP = 0;
		RF_WA1_TEMP = 0;
		RF_RD1_TEMP = 0;
		RF_RD2_TEMP = 0;
		ALUOp_TEMP = 0;
		ALUSrcA_TEMP = 0;
		ALUSrcB_TEMP = 0;
		D_MEM_BE_TEMP = 0;
		D_MEM_WEN_TEMP = 0;
		D_MemRead_TEMP = 0;
		PCSrc_TEMP = 0;
		isJump_TEMP = 0;
		isLoad_TEMP = 0;
		RWSrc_TEMP = 0;
		OPSrc_TEMP = 0;
		RF_WE_TEMP = 0;
		NUM_CHECK_TEMP = 0;
	end

	always @ (posedge CLK) begin
		if (RSTn) begin
			if (~FLUSH_IDEX && ~STALL) begin
				PC_TEMP <= PC_IFID;
				ADD_PC_TEMP <= ADD_PC_IFID;
				HALT_IDEX_TEMP <= HALT_IFID;
				IMM_TEMP <= IMM;
				RF_RA1_TEMP <= RF_RA1;
				RF_RA2_TEMP <= RF_RA2;
				RF_WA1_TEMP <= RF_WA1;
			
				RF_RD1_TEMP <= RF_RD1;
				RF_RD2_TEMP <= RF_RD2;

				ALUOp_TEMP <= ALUOp_IFID;
				ALUSrcA_TEMP <= ALUSrcA_IFID;
				ALUSrcB_TEMP <= ALUSrcB_IFID;

				D_MEM_BE_TEMP <= D_MEM_BE_IFID;
				D_MEM_WEN_TEMP <= D_MEM_WEN_IFID;
				D_MemRead_TEMP <= D_MemRead_IFID;
				PCSrc_TEMP <= PCSrc_IFID;
				isJump_TEMP <= isJump_IFID;
				isLoad_TEMP <= isLoad_IFID;
			
				RWSrc_TEMP <= RWSrc_IFID;
				OPSrc_TEMP <= OPSrc_IFID;
				RF_WE_TEMP <= RF_WE_IFID;
				NUM_CHECK_TEMP <= NUM_CHECK_IFID;
			end
			if (FLUSH_IDEX) begin
				PC_TEMP <= 0;
				ADD_PC_TEMP <= 0;
				HALT_IDEX_TEMP <= 0;
				IMM_TEMP <= 0;
				RF_RA1_TEMP <= 0;
				RF_RA2_TEMP <= 0;
				RF_WA1_TEMP <= 0;
				RF_RD1_TEMP <= 0;
				RF_RD2_TEMP <= 0;
				ALUOp_TEMP <= 0;
				ALUSrcA_TEMP <= 0;
				ALUSrcB_TEMP <= 0;
				D_MEM_BE_TEMP <= 0;
				D_MEM_WEN_TEMP <= 0;
				D_MemRead_TEMP <= 0;
				PCSrc_TEMP <= 0;
				isJump_TEMP <= 0;
				isLoad_TEMP <= 0;
				RWSrc_TEMP <= 0;
				OPSrc_TEMP <= 0;
				RF_WE_TEMP <= 0;
				NUM_CHECK_TEMP <= 0;
			end		
		end
	end
		

endmodule
