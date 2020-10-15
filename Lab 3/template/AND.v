module AND(
    input wire [31:0] A,
    input wire B,
    output wire Out
    );

    reg TEMP;
    assign Out = TEMP;
    
    initial TEMP = 0;
    
    always @ (*) begin
        if (A == 1 && B == 1) TEMP = 1;
        else TEMP = 0;
    end
endmodule