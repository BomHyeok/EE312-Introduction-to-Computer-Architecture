module PR_EXMEM(
	input wire CLK,
	input wire RSTn,
   // MEM
   input wire [3:0] D_MEM_BE_IDEX, 
   input wire D_MEM_WEN_IDEX, D_MemRead_IDEX, isJump_IDEX, isLoad_IDEX,
	input wire [1:0] PCSrc_IDEX,
   output wire [3:0] D_MEM_BE, 
   output wire D_MEM_WEN, D_MemRead, isJump, isLoad,
	output wire [1:0] PCSrc,
   // WB
   input wire [1:0] RWSrc_IDEX, OPSrc_IDEX,
   input wire RF_WE_IDEX, NUM_CHECK_IDEX,
   output wire [1:0] RWSrc_EXMEM, OPSrc_EXMEM,
   output wire RF_WE_EXMEM, NUM_CHECK_EXMEM,
   // except signals
   input wire [31:0] ALU_RESULT, ADD_PC_IDEX,
   input wire [4:0] WA_IDEX,
   input wire HALT_IDEX, Branch_Cond,
   output wire [31:0] ALUOUT_EXMEM, ADD_PC_EXMEM,
   output wire [4:0] WA_EXMEM,
   output wire HALT_EXMEM, Branch_Cond_EXMEM
);

    reg [3:0] _D_MEM_BE;
    reg [1:0] _RWSrc_EXMEM, _OPSrc_EXMEM, _PCSrc;
    reg _D_MEM_WEN, _D_MemRead, _RF_WE_EXMEM, _HALT_EXMEM, _Branch_Cond_EXMEM, _NUM_CHECK_EXMEM, _isJump, _isLoad;
    reg [31:0] _ALUOUT_EXMEM, _ADD_PC_EXMEM;
    reg [4:0] _WA_EXMEM;

    assign D_MEM_BE = _D_MEM_BE;
    assign D_MEM_WEN = _D_MEM_WEN;
    assign D_MemRead = _D_MemRead;
	assign isJump = _isJump;
	assign isLoad = _isLoad;
	assign PCSrc = _PCSrc;
    assign RWSrc_EXMEM = _RWSrc_EXMEM;
    assign OPSrc_EXMEM = _OPSrc_EXMEM;
    assign RF_WE_EXMEM = _RF_WE_EXMEM;
	assign NUM_CHECK_EXMEM = _NUM_CHECK_EXMEM;
    assign ALUOUT_EXMEM = _ALUOUT_EXMEM;
    assign ADD_PC_EXMEM = _ADD_PC_EXMEM;
    assign WA_EXMEM = _WA_EXMEM;
    assign HALT_EXMEM = _HALT_EXMEM;
    assign Branch_Cond_EXMEM = _Branch_Cond_EXMEM;

    initial begin
        _D_MEM_BE = 0;
        _D_MEM_WEN = 1;
        _D_MemRead = 0;
	_isJump = 0;
	_isLoad = 0;
	_PCSrc = 0;
        _RWSrc_EXMEM = 0;
        _OPSrc_EXMEM = 0;
        _RF_WE_EXMEM = 0;
	_NUM_CHECK_EXMEM = 0;
        _ALUOUT_EXMEM = 0;
        _ADD_PC_EXMEM = 0;
        _WA_EXMEM = 0;
        _HALT_EXMEM = 0;
        _Branch_Cond_EXMEM = 0;
    end

    always @ (posedge CLK) begin
        if (RSTn) begin
            _D_MEM_BE = D_MEM_BE_IDEX;
            _D_MEM_WEN = D_MEM_WEN_IDEX;
            _D_MemRead = D_MemRead_IDEX;
		_isJump = isJump_IDEX;
		_isLoad = isLoad_IDEX;
		_PCSrc = PCSrc_IDEX;
            _RWSrc_EXMEM = RWSrc_IDEX;
            _OPSrc_EXMEM = OPSrc_IDEX;
            _RF_WE_EXMEM = RF_WE_IDEX;
		_NUM_CHECK_EXMEM = NUM_CHECK_IDEX;
            _ALUOUT_EXMEM = ALU_RESULT;
            _ADD_PC_EXMEM = ADD_PC_IDEX;
            _WA_EXMEM = WA_IDEX;
            _HALT_EXMEM = HALT_IDEX;
            _Branch_Cond_EXMEM = Branch_Cond;
        end
    end

endmodule