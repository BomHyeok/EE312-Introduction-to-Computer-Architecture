module TRANSLATE(
    input wire [31:0] EFFECTIVE_ADDR,
    input wire instruction_type,
    input wire data_type,
    output wire [11:0] MEM_ADDR
    );

    always @ (*) begin
        if (instruction_type == 1) begin
            MEM_ADDR = EFFECTIVE_ADDR[11:0] & 12'hfff;
        end
        else if (data_type == 1) begin
            MEM_ADDR = EFFECTIVE_ADDR[14:0] & 15'h3fff;
        end
    end
endmodule
