module FORWARD(
    input wire RF_WE_EXMEM, RF_WE_MEMWB, isLoad, isJump,
    input wire [4:0] RF_RA1, RF_RA2, WA_EXMEM, WA_MEMWB,
    input wire [31:0] RF_RD1_IDEX, RF_RD2_IDEX, ALUOUT_EXMEM, ADD_PC_EXMEM, RF_WD, D_MEM_DI,
    output wire [31:0] RF_RD1_OUT, RF_RD2_OUT
    );

    reg [31:0] _RF_RD1_OUT, _RF_RD2_OUT;
    
    assign  RF_RD1_OUT = _RF_RD1_OUT;
    assign  RF_RD2_OUT = _RF_RD2_OUT;

    initial begin
        _RF_RD1_OUT = 0;
        _RF_RD2_OUT = 0;
    end

    always @ (*) begin
        _RF_RD1_OUT = RF_RD1_IDEX;
        _RF_RD2_OUT = RF_RD2_IDEX;

        if (RF_WE_EXMEM) begin
            if (RF_RA1 != 0 && RF_RA1 == WA_EXMEM) begin
                if (isLoad) begin
                //    STALL
                    _RF_RD1_OUT = D_MEM_DI;
                end
                else begin
                    if (isJump) _RF_RD1_OUT = ADD_PC_EXMEM;
                    else _RF_RD1_OUT = ALUOUT_EXMEM;
                end
            end
            if (RF_RA2 != 0 && RF_RA2 == WA_EXMEM) begin
                if (isLoad) begin
                //    STALL;
                    _RF_RD2_OUT = D_MEM_DI;
                end
                else begin
                    if (isJump) _RF_RD2_OUT = ADD_PC_EXMEM;
                    else _RF_RD2_OUT = ALUOUT_EXMEM;
                end
            end
        end
        if (RF_WE_MEMWB) begin
            if ((~RF_WE_EXMEM || RF_RA1 != WA_EXMEM) && RF_RA1 != 0 && RF_RA1 == WA_MEMWB) begin
                _RF_RD1_OUT = RF_WD;
            end
            if ((~RF_WE_EXMEM || RF_RA2 != WA_EXMEM) && RF_RA2 != 0 && RF_RA2 == WA_MEMWB) begin
                _RF_RD2_OUT = RF_WD;
            end
        end
    end

endmodule