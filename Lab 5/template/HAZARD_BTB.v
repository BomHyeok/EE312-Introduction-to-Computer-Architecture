module HAZARD_BTB(
    // for detection
    input wire [1:0] PCSrc,
    input wire Branch_Cond,
    // for PC Prediction check
    input wire [31:0] PC_IDEX, PC_EXMEM, ALUOUT_EXMEM, ADD_PC_EXMEM, 
    output wire [31:0] ACTUAL_PC,
    output wire TAKEN, FLUSH_IFID, FLUSH_IDEX, FLUSH_EXMEM,
    // for BTB
    output wire BTB_WE,
    output wire [31:0] BTBIN,
    output wire [29:0] BTBidx
    );

    reg [31:0] _ACTUAL_PC, _BTBIN;
    reg [29:0] _BTBidx;
    reg _TAKEN, _FLUSH_IFID, _FLUSH_IDEX, _FLUSH_EXMEM, _BTB_WE;

    assign ACUTAL_PC = _ACUTAL_PC;
    assign TAKEN = _TAKEN;
    assign FLUSH_IFID = _FLUSH_IFID;
    assign FLUSH_IDEX = _FLUSH_IDEX;
    assign FLUSH_EXMEM = _FLUSH_EXMEM;
    assign BTB_WE = _BTB_WE;
    assign BTBIN = _BTBIN;
    assign BTBidx = _BTBidx;

    initial begin
        _ACUTAL_PC = 0;
        _TAKEN = 0;
        _FLUSH_IFID = 0;
        _FLUSH_IDEX = 0;
        _FLUSH_EXMEM = 0;
        _BTB_WE = 1;
        _BTBIN = 0;
        _BTBidx = 0;
    end

    always @ (*) begin
        case (PCSrc)
            2'b01 : _ACUTAL_PC = ALUOUT_EXMEM; // JAL
            2'b10 : _ACUTAL_PC = ALUOUT_EXMEM & 32'hfffffffe; // JALR
            2'b11 : if (Branch_Cond == 1) _ACUTAL_PC = ALUOUT_EXMEM; // Branch
            2'b00 : _ACUTAL_PC = ADD_PC_EXMEM; // else
        endcase
        if (_ACTUAL_PC == PC_IDEX) begin
            _FLUSH_IFID = 0;
            _FLUSH_IDEX = 0;
            _FLUSH_EXMEM = 0;
            _TAKEN = 1;
            _BTB_WE = 1;
            _BTBidx = 0;
            _BTBIN = 0;
        end
        else begin
            _FLUSH_IFID = 1;
            _FLUSH_IDEX = 1;
            _FLUSH_EXMEM = 1;
            _TAKEN = 0;
            _BTB_WE = 0;
            _BTBidx = PC_EXMEM[31:2];
            _BTBIN = _ACUTAL_PC;
        end
    end 

endmodule