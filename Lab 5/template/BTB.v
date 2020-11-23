module BTB(
    input wire [29:0] BTBidx,
    input wire CLK, BTB_CSN, WEN, TAKEN,
    input wire [31:0] BTBIN,
    input wire [1:0] 2bitSC_IN,
    output wire PRE_TAKEN,
    output wire [1:0] 2bitSC_OUT,
    output wire [31:0] BTBOUT
    );

    reg [31:0] btbram[0: 256-1];
    reg [31:0] _BTBOUT;
    reg [1:0] _2bitSC_OUT;
    reg _PRE_TAKEN;

    assign BTBOUT = _BTBOUT;
    assign PRE_TAKEN = _PRE_TAKEN;
    assign 2bitSC_OUT = _2bitSC_OUT;

    initial begin
        btbram = 0;
        temp = 0;
        _BTBOUT = 0;
        _2bitSC_OUT = 0;
        _PRE_TAKEN = 0;
    end

    always @ (posedge CLK) begin
        case (2bitSC_IN)
            2'b00 : 
            begin
                if (TAKEN) _2bitSC_OUT = 2'b01;
                else _2bitSC_OUT = 2'b00;
            end
            2'b01 : 
            begin
                if (TAKEN) _2bitSC_OUT = 2'b10;
                else _2bitSC_OUT = 2'b00;
            end
            2'b10 : 
            begin
                if (TAKEN) _2bitSC_OUT = 2'b11;
                else _2bitSC_OUT = 2'b01;
            end
            2'b11 :
            begin
                if (TAKEN) _2bitSC_OUT = 2'b11;
                else _2bitSC_OUT = 2'b10;
            end
        endcase

        if (_2bitSC_OUT == 2'b00 || _2bitSC_OUT == 2'b01) _PRE_TAKEN = 0;
        else _PRE_TAKEN = 1;

        if (~BTB_CSN) begin
            if (WEN) begin
                _BTBOUT = btbram[BTBidx];
            end
            else begin
                btbram[BTBidx] = BTBIN[31:0];
            end
        end
    end

endmodule