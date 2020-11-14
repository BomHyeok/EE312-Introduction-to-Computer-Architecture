module pipeCTRL(
   input wire [31:0] INSTR,
   // EX
   output wire [3:0] ALUOp, 
   output wire ALUSrcA, ALUSrcB,
   // MEM
   output wire [3:0] D_MEM_BE, 
   output wire D_MEM_WEN, MemRead, IorD,
   // WB
   output wire [1:0] RWSrc
   output wire RF_WE
   );

    reg [3:0] _ALUOp, _D_MEM_BE;
    reg [1:0] _RWSrc;
    reg _ALUSrcA, _ALUSrcB, _D_MEM_WEN, _MemRead, _IorD, _RF_WE;

    assign ALUOp = _ALUOp;
    assign ALUSrcA = _ALUSrcA;
   assign ALUSrcB = _ALUSrcB;
    assign D_MEM_BE = _D_MEM_BE;
    assign D_MEM_WEN = _D_MEM_WEN;
    assign D_MemRead = _D_MemRead;
    assign IorD = _IorD;
    assign RWSrc = _RWSrc;
    assign RF_WE = _RF_WE;

    initial begin
        _ALUOp = 0;
        _ALUSrcA = 0;
   _ALUSrcB = 0;
        _D_MEM_BE = 0;
        _D_MEM_WEN = 1;
        _D_MemRead = 0;
   _IorD = 0;
        _RWSrc = 0;
        _RF_WE = 0;
    end

   always@ (*) begin(
      case (INSTR[6:0])
         // JAL
         7'b1101111 :
         begin
            _ALUOp = 0;
            _ALUSrcA = 0;
            _ALUSrcB = 0;
            _D_MEM_BE = 0;
            _D_MEM_WEN = 1;
            _D_MemRead = 0;
            _IorD = 0;
            _RWSrc = 0;
            _RF_WE = 0;
         end
         // JALR
         7'b1100111 :
         begin
         end
         // B(BRANCH) Type (BEQ, BNE, BLT, BGE, BLTU, BGEU)
         7'b1100011 :
         begin
         end
         // I Type Load LW
         7'b0000011 :
         begin
         end
         // SW
         7'b0100011 :
         begin
         end
         // I Type (ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI)
         7'b0010011 :
         begin
         end
         // R Type (ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND)
         7'b0110011 :
         begin
         end
         
    


endmodule