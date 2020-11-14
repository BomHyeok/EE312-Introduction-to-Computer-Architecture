module MUX(
    input wire [31:0] A, B, ALUOUT_EXMEM, ADD_PC, isJump, RF_WD,
    input wire [1:0] Forward,
    input wire S, 
    output wire [31:0] Out
    );

    reg [31:0] TEMP;
    assign Out = TEMP;
    initial TEMP = 0;
    
    always @ (*) begin
        case (Forward)
            2'b00 : 
            begin
                if (S == 0) TEMP = A;
                else TEMP = B;
            end
            2'b01 : 
            begin
                if (isJump) TEMP = ADD_PC;
                else TEMP = ALUOUT_EXMEM;
            end
            2'b10 : TEMP = RF_WD;
        endcase
    end
endmodule