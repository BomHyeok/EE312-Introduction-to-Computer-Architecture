module PR_MEMWB(
	input wire CLK,
	input wire RSTn,
   // WB
   input wire [1:0] RWSrc_EXMEM, OPSrc_EXMEM,
   input wire RF_WE_EXMEM, NUM_CHECK_EXMEM,
   output wire [1:0] RWSrc, OPSrc,
   output wire RF_WE, NUM_CHECK,
   // except signals
   input wire [31:0] ALUOUT_EXMEM, ADD_PC_EXMEM, D_MEM_DI,
   input wire [4:0] WA_EXMEM,
   input wire HALT_EXMEM, Branch_Cond_EXMEM,
   output wire [31:0] ALUOUT_MEMWB, ADD_PC_MEMWB, D_MEM_DI_OUT,
   output wire [4:0] WA_MEMWB,
   output wire HALT, Branch_Cond_MEMWB
);

    reg [1:0] _RWSrc, _OPSrc;
    reg _RF_WE, _Branch_Cond_MEMWB, _NUM_CHECK, _HALT;
    reg [31:0] _ALUOUT_MEMWB, _ADD_PC_MEMWB, _D_MEM_DI_OUT;
    reg [4:0] _WA_MEMWB;

    assign RWSrc = _RWSrc;
    assign OPSrc = _OPSrc;
    assign RF_WE = _RF_WE;
	assign NUM_CHECK = _NUM_CHECK;
    assign ALUOUT_MEMWB = _ALUOUT_MEMWB;
    assign ADD_PC_MEMWB = _ADD_PC_MEMWB;
    assign D_MEM_DI_OUT = _D_MEM_DI_OUT;
    assign WA_MEMWB = _WA_MEMWB;
    assign HALT = _HALT;
    assign Branch_Cond_MEMWB = _Branch_Cond_MEMWB;

    initial begin
        _RWSrc = 0;
        _OPSrc = 0;
        _RF_WE = 0;
	_NUM_CHECK = 0;
        _ALUOUT_MEMWB = 0;
        _ADD_PC_MEMWB = 0;
        _D_MEM_DI_OUT = 0;
        _WA_MEMWB = 0;
        _HALT = 0;
        _Branch_Cond_MEMWB = 0;
    end

    always @ (negedge CLK) begin
        if (RSTn) begin
            _RWSrc = RWSrc_EXMEM;
            _OPSrc = OPSrc_EXMEM;
            _RF_WE = RF_WE_EXMEM;
		_NUM_CHECK = NUM_CHECK_EXMEM;
            _ALUOUT_MEMWB = ALUOUT_EXMEM;
            _ADD_PC_MEMWB = ADD_PC_EXMEM;
            _D_MEM_DI_OUT = D_MEM_DI;
            _WA_MEMWB = WA_EXMEM;
            _HALT = HALT_EXMEM;
            _Branch_Cond_MEMWB = Branch_Cond_EXMEM;
        end
    end

endmodule