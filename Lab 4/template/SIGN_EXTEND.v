module SIGN_EXTEND(
    input wire [31:0] IMM,
    output wire [31:0] IMM_EX
    );

    reg [31:0] TEMP;
    assign IMM_EX = TEMP;
    initial TEMP = 0;
    
    always @ (*) begin
        TEMP = IMM;
        if (IMM[20]) TEMP[31:21] = 11'h7ff;
        if (~IMM[20] && IMM[12]) TEMP[31:13] = 19'h7ffff;
        if (~IMM[20] && ~IMM[12] && IMM[11]) TEMP[31:12] = 20'hfffff;
    end
endmodule