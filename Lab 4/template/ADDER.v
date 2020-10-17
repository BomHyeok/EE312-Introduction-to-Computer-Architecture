module ADDER(A,B,Out);

    input wire [31:0] A;
    input wire [31:0] B;
    output wire [31:0] Out;

    reg [31:0] C;
    assign Out = C;
    
    initial C = 0;

    always @ (A, B, OP) begin
        C = A + B;
    end
endmodule
