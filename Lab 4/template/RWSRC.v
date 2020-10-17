module RWSRC(
    input wire [31:0] ADD_PC, D_MEM_DI, ALU_RESULT,
    input wire [1:0] RWSrc,
    input wire RF_WE,
    output wire RF_WD
    );

    reg TEMP;
    assign RF_WD = TEMP;
    
    initial TEMP = 0;
    
    always @ (*) begin
        if (RF_WE) begin
            case (RWSrc)
                2'b00 : TEMP = ADD_PC;
                2'b01 : TEMP = D_MEM_DI;
                2'b10 : TEMP = ALU_RESULT;
            endcase
        end
    end
endmodule