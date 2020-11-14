module ADDER(
    input wire [31:0] A, B,
    output wire [31:0] Out
    );
    reg [31:0] C;
    assign Out = C;
    
    initial C = 0;

    always @ (*) begin
        C = A + B;
    end
endmodule
