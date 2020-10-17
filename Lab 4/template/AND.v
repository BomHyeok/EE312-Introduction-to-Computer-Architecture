module AND(
    input wire A,B,
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