module CTRL(
	input wire [31:0] _INSTR,

	output wire [31:0] IMM,
	output wire [31:0] RF_WD,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA,
	output wire RF_WE,
	output wire INSTR_TYPE,
	output wire [3:0] OP,
	output wire HALT
	
);
	reg [31:0] _IMM, INSTR, _RF_WD;
	reg [4:0] _RF_RA1, _RF_RA2, _RF_WA;
	reg PRE_HALT, _HALT, _RF_WE, _INSTR_TYPE;
	reg [3:0] _OP;

	assign IMM = _IMM;
	assign RF_RA1 = _RF_RA1;
	assign RF_RA2 = _RF_RA2;
	assign RF_WE = _RF_WE;
	assign RF_WD = _RF_WD;
	assign INSTR_TYPE = _INSTR_TYPE;
	assign OP = _OP;
	assign HALT = _HALT;

	initial begin
		PRE_HALT <= 0;
	end

	always @ (*) begin
		INSTR = _INSTR;
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
		case (INSTR[6:0])
			// I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
			7'b0010011 :
			begin
				_IMM[11:0] = INSTR[31:20];
				_RF_RA1 = INSTR[19:15];
				_RF_WE = 1;
				_RF_WA = INSTR[11:7];
				_OP = INSTR[14:12];
				_INSTR_TYPE = 1;
			end
		
			// R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
			7'b0110011 :
			begin
				_RF_RA1 = INSTR[19:15];
				_RF_RA2 = INSTR[24:20];
				_RF_WE = 1;
				_RF_WA = INSTR[11:7];
				_OP = INSTR[14:12];
				_INSTR_TYPE = 0;
			end
			default: _RF_WD = 0; // need to modify
		endcase
	end
endmodule
