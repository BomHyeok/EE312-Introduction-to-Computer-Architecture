module SIGN_EXTEND(
    input wire [31:0] IMM,
    input wire isJAL,
    output wire [31:0] IMM_EX
    );

    reg [31:0] TEMP;
    assign IMM_EX = TEMP;
    
    always @ (*) begin
        if (isJAL) TEMP = IMM;
        else begin
            TEMP[11:0] = IMM[11:0];
            if (IMM[11] == 0) TEMP[31:12] = 0;
            else TEMP[31:12] = 20'hfffff;
        end
    end
endmodule