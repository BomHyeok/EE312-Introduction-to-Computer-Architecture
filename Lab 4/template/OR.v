module OR(
    input wire A,
    input wire B,
    output wire Out
    );

    reg TEMP;
    assign Out = TEMP;
    
    initial TEMP = 0;
    
    always @ (*) begin
        if (A == 0 && B == 0) TEMP = 0;
        else TEMP = 1;
    end
endmodule