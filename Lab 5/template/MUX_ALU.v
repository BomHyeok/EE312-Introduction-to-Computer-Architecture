module MUX_ALU(
    input wire [31:0] A, B, ALUOUT_EXMEM, ADD_PC_EXMEM, RF_WD, 
    input wire [1:0] Forward,
    input wire S, isJump, 
    output wire [31:0] Out,
    // instead of stall
    input wire [31:0] D_MEM_DI
    );

    reg [31:0] TEMP;
    assign Out = TEMP;
    initial TEMP = 0;
    
    always @ (*) begin
        case (Forward)
            2'b00 : // No Forwarding
            begin
                if (S == 0) TEMP = A;
                else TEMP = B;
            end
            2'b01 : // Forwarding from EXMEM
            begin
                if (isJump) TEMP = ADD_PC_EXMEM;
                else TEMP = ALUOUT_EXMEM;
            end
            2'b10 : // Forwarding from MEMWB
            begin
                TEMP = RF_WD; 
            end
            // instead of stall
            2'b11 : TEMP = D_MEM_DI;
        endcase
    end
endmodule