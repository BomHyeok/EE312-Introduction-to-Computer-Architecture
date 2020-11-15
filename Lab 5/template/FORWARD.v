module FORWARD(
    input wire RegWrite_EXMEM, RegWrite_MEMWB, isLoad,
    input wire [4:0] RF_RA1, RF_RA2, WA_EXMEM, WA_MEMWB,
    output wire [1:0] ForwardA, ForwardB
    );

    reg [1:0] _ForwardA, _ForwardB;

    assign ForwardA = _ForwardA;
    assign ForwardB = _ForwardB;

    initial begin
        _ForwardA = 0;
        _ForwardB = 0;
    end

    always @ (*) begin
        _ForwardA = 0;
        _ForwardB = 0;

        if (RegWrite_EXMEM) begin
            if (RF_RA1 != 0 && RF_RA1 == WA_EXMEM) begin
                if (isLoad) begin
                //    STALL;
                    _ForwardA = 2'b11;
                end
                else begin
                    _ForwardA = 2'b01;
                end
            end
            if (RF_RA2 != 0 && RF_RA2 == WA_EXMEM) begin
                if (isLoad) begin
                //    STALL;
                    _ForwardB = 2'b11;
                end
                else begin
                    _ForwardB = 2'b01;
                end
            end
        end
        if (RegWrite_MEMWB) begin
            if ((~RegWrite_EXMEM || RF_RA1 != WA_EXMEM) && RF_RA1 != 0 && RF_RA1 == WA_MEMWB) begin
                _ForwardA = 2'b10;
            end
            if ((~RegWrite_EXMEM || RF_RA2 != WA_EXMEM) && RF_RA2 != 0 && RF_RA2 == WA_MEMWB) begin
                _ForwardB = 2'b10;
            end
        end
    end

endmodule