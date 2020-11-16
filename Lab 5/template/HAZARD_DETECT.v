module HAZARD_DETECT(
    // for detection
    input wire [1:0] PCSrc,
    input wire BranchCond,
    // for PC Update
    input wire [31:0] ALUOUT_EXMEM,
    output wire [31:0] Updated_PC,
    output wire Hazard_Sig, FLUSH_IFID, FLUSH_IDEX, FLUSH_EXMEM 
    );

    reg [31:0] _Updated_PC;
    reg _Hazard_Sig, _FLUSH_IFID, _FLUSH_IDEX, _FLUSH_EXMEM;

    assign Updated_PC = _Updated_PC;
    assign Hazard_Sig = _Hazard_Sig;
    assign FLUSH_IFID = _FLUSH_IFID;
    assign FLUSH_IDEX = _FLUSH_IDEX;
    assign FLUSH_EXMEM = _FLUSH_EXMEM;

    initial begin
        _Updated_PC = 0;
        _Hazard_Sig = 0;
        _FLUSH_IFID = 0;
        _FLUSH_IDEX = 0;
        _FLUSH_EXMEM = 0;
    end

    always @ (*) begin
        case (PCSrc)
            2'b01 : // JAL
            begin
                _Updated_PC = ALUOUT_EXMEM;
                _Hazard_Sig = 1;
                _FLUSH_IFID = 1;
                _FLUSH_IDEX = 1;
                _FLUSH_EXMEM = 1;
            end
            2'b10 : // JALR
            begin
                _Updated_PC = ALUOUT_EXMEM & 32'hfffffffe;
                _Hazard_Sig = 1;
                _FLUSH_IFID = 1;
                _FLUSH_IDEX = 1;
                _FLUSH_EXMEM = 1;
            end
            2'b11 : // Branch
            begin
                if (BranchCond == 1) begin
                    _Updated_PC = ALUOUT_EXMEM;
                    _Hazard_Sig = 1;
                    _FLUSH_IFID = 1;
                    _FLUSH_IDEX = 1;
                    _FLUSH_EXMEM = 1;
                end
            end
            2'b00 : // else
            begin
                _Updated_PC = 0;
                _Hazard_Sig = 0;
                _FLUSH_IFID = 0;
                _FLUSH_IDEX = 0;
                _FLUSH_EXMEM = 0;
            end
        endcase
    end 

endmodule