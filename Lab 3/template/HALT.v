module HALT(
    input wire [31:0] INSTR,
    output wire HALT
    );

    reg _HALT;
    reg PRE_HALT;
    assign HALT = _HALT;
    
    always @ (*) begin
        if (INSTR == 32'h00c00093) PRE_HALT = 1;
        else PRE_HALT = 0;
        if (PRE_HALT == 1 && INSTR == 32'h00008067) _HALT = 1;
    end
endmodule