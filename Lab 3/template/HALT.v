module HALT(
    input wire [31:0] INSTR, PRE_INSTR,
    output wire HALT
    );

    reg _HALT;
    assign HALT = _HALT;

    initial begin
        _HALT = 0;
    end

    always @ (*) begin
        if (PRE_INSTR == 32'h00c00093 && INSTR == 32'h00008067) _HALT = 1;
        else _HALT = 0;
    end
endmodule