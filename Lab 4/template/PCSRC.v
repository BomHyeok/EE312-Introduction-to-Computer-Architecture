module PCSRC(
    input wire [31:0] ADD_PC, ALU_RESULT,
    input wire [1:0] PCSrc,
    input wire isBranchTaken,
    output wire [31:0] Updated_PC
    );

    reg [31:0] TEMP;
    assign Updated_PC = TEMP;
    
    initial TEMP = 0;
    
    always @ (*) begin
        case (PCSrc)
            2'b00 : TEMP = ADD_PC;
            2'b01 : TEMP = ALU_RESULT;
            2'b10 : TEMP = ALU_RESULT & 32'hfffffffe;
            2'b11 : 
            begin
                if (isBranchTaken) TEMP = ALU_RESULT;
                else TEMP = ADD_PC;
            end
        endcase
    end
endmodule