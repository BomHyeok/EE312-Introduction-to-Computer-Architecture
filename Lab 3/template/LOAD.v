module LOAD(
    input wire [31:0] SRC,
    input wire [2:0] Lfunct,
    output wire [31:0] Out
 );

    reg [31:0] TEMP;
    assign Out = TEMP;
    initial TEMP = 0;

    always @ (SRC, Lfunct, Out) begin
        case(Lfunct)
        // LB
            3'b000 : 
            begin
                TEMP[7:0] = SRC[7:0];
                if (SRC[7] == 0) TEMP[31:8] = 0;
                else TEMP[31:8] = 24'hffffff;
            end
        // LH
            3'b001 : 
            begin
                TEMP[15:0] = SRC[15:0];
                if (SRC[15] == 0) TEMP[31:16] = 0;
                else TEMP[31:16] = 16'hffff;
            end
        // LW
            3'b010 : TEMP = SRC;   
        // LBU
            3'b100 : 
            begin
                TEMP[7:0] = SRC[7:0];
                TEMP[31:8] = 0;
            end
        // LHU
            3'b101 : 
            begin
                TEMP[15:0] = SRC[15:0];
                TEMP[31:16] = 0;
            end
        endcase
    end
endmodule