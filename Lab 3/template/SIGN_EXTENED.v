module SIGN_EXTENED(
    input wire [31:0] IMM,
    output wire [31:0] IMM_EX
    );

    reg [31:0] TEMP;
    assign IMM_EX = TEMP;
    
    always @ (*) begin
        if (IMM[11] == 0) begin
            TEMP[31:12] = 0;
        end
        else if (IMM[11] == 0) begin
            TEMP[31:12] = 20'hfffff;
        end
    end
endmodule