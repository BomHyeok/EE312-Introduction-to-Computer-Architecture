module PR_MEMWB(
   // WB
   input wire [1:0] RWSrc_EXMEM,
   input wire RF_WE_EXMEM,
   output wire [1:0] RWSrc,
   output wire RF_WE,
   // except signals
   input wire [31:0] ALUOUT_EXMEM, ADD_PC_EXMEM, D_MEM_DI,
   input wire [4:0] WA_EXMEM,
   output wire [31:0] ALUOUT_MEMWB, ADD_PC_MEMWB, D_MEM_DI_OUT,
   output wire [4:0] WA_MEMWB
);

    reg [1:0] _RWSrc;
    reg _RF_WE;
    reg [31:0] _ALUOUT_MEMWB, _ADD_PC_MEMWB, _D_MEM_DI_OUT;
    reg [4:0] _WA_MEMWB;

    assign RWSrc = _RWSrc;
    assign RF_WE = _RF_WE;
    assign ALUOUT_MEMWB = _ALUOUT_MEMWB;
    assign ADD_PC_MEMWB = _ADD_PC_MEMWB;
    assign D_MEM_DI_OUT = _D_MEM_DI_OUT;
    assign WA_MEMWB = _WA_MEMWB;

    initial begin
        _RWSrc = 0;
        _RF_WE = 0;
        _ALUOUT_MEMWB = 0;
        _ADD_PC_MEMWB = 0;
        _D_MEM_DI_OUT = 0;
        _WA_MEMWB = 0;
    end

    always @ (negedge CLK) begin
        if (RSTn) begin
            _RWSrc = RWSrc_EXMEM;
            _RF_WE = RF_WE_EXMEM;
            _ALUOUT_MEMWB = ALUOUT_EXMEM;
            _ADD_PC_MEMWB = ADD_PC_EXMEM;
            _D_MEM_DI_OUT = D_MEM_DI;
            _WA_MEMWB = WA_EXMEM;
        end
    end

endmodule