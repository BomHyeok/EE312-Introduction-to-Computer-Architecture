module TRANSLATE(
    input wire [31:0] EFFECTIVE_ADDR,
    input wire MemRead,
    input wire IorD,
    output wire [11:0] MEM_ADDR
    );

    reg [11:0] TEMP_ADDR;
    assign MEM_ADDR = TEMP_ADDR;
    initial TEMP_ADDR = 0;
    
    always @ (*) begin
        if (MemRead) begin
            if (IorD == 0) TEMP_ADDR = EFFECTIVE_ADDR[11:0] & 12'hfff;
            else TEMP_ADDR = EFFECTIVE_ADDR[14:0] & 15'h3fff;
        end
    end
endmodule
