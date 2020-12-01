module FORWARD(
    input wire RegWrite_EXMEM, RegWrite_MEMWB, isLoad,
    input wire [4:0] RF_RA1, RF_RA2, WA_EXMEM, WA_MEMWB,
    input wire [1:0] OPSrc_IDEX,
    input wire ALUSrcB,
    output wire [1:0] ForwardA, ForwardB, BranchForwardA, BranchForwardB, SWForwardB
    );

    reg [1:0] _ForwardA, _ForwardB, _BranchForwardA, _BranchForwardB, _SWForwardB;

    assign ForwardA = _ForwardA;
    assign ForwardB = _ForwardB;
    assign BranchForwardA = _BranchForwardA;
    assign BranchForwardB = _BranchForwardB;
    assign SWForwardB = _SWForwardB;

    initial begin
        _ForwardA = 0;
        _ForwardB = 0;
        _BranchForwardA = 0;
        _BranchForwardB = 0;
        _SWForwardB = 0;
    end

    always @ (*) begin
        _ForwardA = 0;
        _ForwardB = 0;
        _BranchForwardA = 0;
        _BranchForwardB = 0;
        _SWForwardB = 0;

        if (RegWrite_EXMEM) begin
            if (RF_RA1 != 0 && RF_RA1 == WA_EXMEM) begin
                // Branch(OPSrc = 2'b10)
                if (OPSrc_IDEX == 2'b10) begin
                    if (isLoad) begin
                    //    STALL;
                        _BranchForwardA = 2'b11;
                    end
                    else begin
                        _BranchForwardA = 2'b01;
                    end
                end
                else begin
                    if (isLoad) begin
                    //    STALL;
                        _ForwardA = 2'b11;
                    end
                    else begin
                        _ForwardA = 2'b01;
                    end
                end
            end
            // only Branch(OPSrc = 2'b10) and R-type(ALUSrcB = 0) SW(OPSrc = 2'b01) need RA2 forwarding
            if (RF_RA2 != 0 && RF_RA2 == WA_EXMEM) begin
                if (OPSrc_IDEX == 2'b10) begin
                    if (isLoad) begin
                    //    STALL;
                        _BranchForwardB = 2'b11;
                    end
                    else begin
                        _BranchForwardB = 2'b01;
                    end
                end
                if (ALUSrcB == 0) begin
                    if (isLoad) begin
                    //    STALL;
                        _ForwardB = 2'b11;
                    end
                    else begin
                        _ForwardB = 2'b01;
                    end
                end
                if (OPSrc_IDEX == 2'b01) begin
                    if (isLoad) begin
                    //    STALL;
                        _SWForwardB = 2'b11;
                    end
                    else begin
                        _SWForwardB = 2'b01;
                    end
                end
            end
        end
        if (RegWrite_MEMWB) begin
            if ((~RegWrite_EXMEM || RF_RA1 != WA_EXMEM) && RF_RA1 != 0 && RF_RA1 == WA_MEMWB) begin
                if (OPSrc_IDEX == 2'b10) begin
                    _BranchForwardA = 2'b10;
                end
                else begin
                    _ForwardA = 2'b10;
                end
            end
            // only Branch(PCSrc = 2'b11) and R-type(ALUSrcB = 0) need RA2 forwarding
            if ((~RegWrite_EXMEM || RF_RA2 != WA_EXMEM) && RF_RA2 != 0 && RF_RA2 == WA_MEMWB) begin
                if (OPSrc_IDEX == 2'b10) begin
                    _BranchForwardB = 2'b10;
                end
                if (ALUSrcB == 0) begin
                    _ForwardB = 2'b10;
                end
                if (OPSrc_IDEX == 2'b01) begin
                    _SWForwardB = 2'b10;
                end
            end
        end
    end

endmodule