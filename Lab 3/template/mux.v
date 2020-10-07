module MUX(
    input wire [31:0] A,
    input wire [31:0] B,
    input wire S,
    output wire [31:0] Out
    );

    reg [31:0] TEMP;
    assign Out = TEMP;
    initial TEMP = 0;
    
    always @ (*) begin
        if (S == 0) begin
            TEMP = A;
        end
        else if (S == 1) begin
            TEMP = B;
        end
    end
endmodule