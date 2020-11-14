module PR_EXMEM(
   // MEM
   input wire [3:0] D_MEM_BE_IDEX, 
   input wire D_MEM_WEN_IDEX, D_MemRead_IDEX,
   output wire [3:0] D_MEM_BE, 
   output wire D_MEM_WEN, D_MemRead, 
   // WB
   input wire [1:0] RWSrc_IDEX,
   input wire RF_WE_IDEX,
   output wire [1:0] RWSrc_EXMEM,
   output wire RF_WE_EXMEM,
   // except signals
   input wire [31:0] ALU_RESULT, ADD_PC_IDEX,
   input wire [4:0] WA_IDEX,
   output wire [31:0] ALUOUT_EXMEM, ADD_PC_EXMEM,
   output wire [4:0] WA_EXMEM
);

    reg [3:0] _D_MEM_BE;
    reg [1:0] _RWSrc_EXMEM;
    reg _D_MEM_WEN, _D_MemRead, _RF_WE_EXMEM;
    reg [31:0] _ALUOUT_EXMEM, _ADD_PC_EXMEM;
    reg [4:0] _WA_EXMEM;

    assign D_MEM_BE = _D_MEM_BE;
    assign D_MEM_WEN = _D_MEM_WEN;
    assign D_MemRead = _D_MemRead;
    assign RWSrc_EXMEM = _RWSrc_EXMEM;
    assign RF_WE_EXMEM = _RF_WE_EXMEM;
    assign ALUOUT_EXMEM = _ALUOUT_EXMEM;
    assign ADD_PC_EXMEM = _ADD_PC_EXMEM;
    assign WA_EXMEM = _WA_EXMEM;

    initial begin
        _D_MEM_BE = 0;
        _D_MEM_WEN = 1;
        _D_MemRead = 0;
        _RWSrc_EXMEM = 0;
        _RF_WE_EXMEM = 0;
        _ALUOUT_EXMEM = 0;
        _ADD_PC_EXMEM = 0;
        _WA_EXMEM = 0;
    end

    always @ (negedge CLK) begin
        if (RSTn) begin
            _D_MEM_BE = D_MEM_BE_IDEX;
            _D_MEM_WEN = D_MEM_WEN_IDEX;
            _D_MemRead = D_MemRead_IDEX;
            _RWSrc_EXMEM = RWSrc_IDEX;
            _RF_WE_EXMEM = RF_WE_IDEX;
            _ALUOUT_EXMEM = ALU_RESULT;
            _ADD_PC_EXMEM = ADD_PC_IDEX;
            _WA_EXMEM = WA_IDEX;
        end
    end

endmodule