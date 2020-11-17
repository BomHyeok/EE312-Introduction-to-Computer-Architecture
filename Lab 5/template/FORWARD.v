module FORWARD(
    input wire RegWrite_EXMEM, RegWrite_MEMWB, isLoad,
    input wire [4:0] RF_RA1, RF_RA2, WA_EXMEM, WA_MEMWB,
    input wire [1:0] PCSrc_IDEX,
    output wire [1:0] ForwardA, ForwardB, BranchForwardA, BranchForwardB
    );

    reg [1:0] _ForwardA, _ForwardB, _BranchForwardA, _BranchForwardB;

    assign ForwardA = _ForwardA;
    assign ForwardB = _ForwardB;
    assign BranchForwardA = _BranchForwardA;
    assign BranchForwardB = _BranchForwardB;

    initial begin
        _ForwardA = 0;
        _ForwardB = 0;
        _BranchForwardA = 0;
        _BranchForwardB = 0;
    end

    always @ (*) begin
        _ForwardA = 0;
        _ForwardB = 0;
        _BranchForwardA = 0;
        _BranchForwardB = 0;

        // JAL(PCSrc = 2'b01): Don't use register
        if (RegWrite_EXMEM && PCSrc_IDEX != 2'b01) begin
            if (RF_RA1 != 0 && RF_RA1 == WA_EXMEM) begin
                // Branch(PCSrc = 2'b11)
                if (PCSrc_IDEX == 2'b11) begin
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
            // JALR(PCSrc = 2'b10): Don't use RA2
            if (RF_RA2 != 0 && RF_RA2 == WA_EXMEM && PCSrc_IDEX != 2'b10) begin
                // Branch(PCSrc = 2'b11)
                if (PCSrc_IDEX == 2'b11) begin
                    if (isLoad) begin
                    //    STALL;
                        _BranchForwardB = 2'b11;
                    end
                    else begin
                        _BranchForwardB = 2'b01;
                    end
                end
                else begin
                    if (isLoad) begin
                    //    STALL;
                        _ForwardB = 2'b11;
                    end
                    else begin
                        _ForwardB = 2'b01;
                    end
                end
            end
        end
        if (RegWrite_MEMWB && PCSrc_IDEX != 2'b01) begin
            if ((~RegWrite_EXMEM || RF_RA1 != WA_EXMEM) && RF_RA1 != 0 && RF_RA1 == WA_MEMWB) begin
                if (PCSrc_IDEX == 2'b11) begin
                    _BranchForwardA = 2'b10;
                end
                else begin
                    _ForwardA = 2'b10;
                end
            end
            // JALR(PCSrc = 2'b10): Don't use RA2
            if ((~RegWrite_EXMEM || RF_RA2 != WA_EXMEM) && RF_RA2 != 0 && RF_RA2 == WA_MEMWB && PCSrc_IDEX != 2'b10) begin
                if (PCSrc_IDEX == 2'b11) begin
                    _BranchForwardB = 2'b10;
                end
                else begin
                    _ForwardB = 2'b10;
                end
            end
        end
    end

endmodule