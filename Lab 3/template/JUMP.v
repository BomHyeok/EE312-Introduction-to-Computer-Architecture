module JUMP(
    input wire [31:0] PC, ALU_RESULT, 
    input wire isJAL, isJALR,
    output wire [31:0] Target_JUMP
    );

    reg [31:0] _Target;
    assign Target_JUMP = _Target;
    
    always @ (*) begin
        if (isJAL) _Target = PC + ALU_RESULT; // ALU_RESULT = ALU(RF_RD1 = 0, ALUSRC = IMM_EX = IMM, OP = 0 (ADD)) = IMM
        if (isJALR) _Target = ALU_RESULT & 32'hfffffffe;
    end
endmodule