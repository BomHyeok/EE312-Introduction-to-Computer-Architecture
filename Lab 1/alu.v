 `timescale 1ns / 100ps
 
 module ALU(A,B,OP,C,Cout);
 
     input [15:0]A;
     input [15:0]B;
     input [3:0]OP;
     output reg [15:0]C;
     output reg Cout;
     reg Var;
 
     always@(A, B, OP) begin
 
         Var = 0;
         Cout = 0;
         C = 0;

         case(OP)
             4'b0000: begin // ADDITION
                 C = A + B;
                 if (A[15]==1 && B[15]==1 && C[15]==0)
                     Cout = 1;
                 else if (A[15]==0 && B[15]==0 && C[15]==1)
                     Cout = 1;
             end
             4'b0001: begin // SUBTRACTION
                 C = A - B;
                 if (A[15]==1 && B[15]==0 && C[15]==0)
                     Cout = 1;
                 else if (A[15]==0 && B[15]==1 && C[15]==1)
                     Cout = 1;
             end
 
             4'b0010: C = A & B; // AND
             4'b0011: C = A | B; // OR
             4'b0100: C = A ~& B; // NAND
             4'b0101: C = A ~| B; // NOR
             4'b0110: C = A ^ B; // XOR
             4'b0111: C = A ~^ B; // XNOR
             4'b1000: C = A; // IDENTITY
             4'b1001: C = ~A; // NOT
 
             4'b1010: C = A>>1; // LOGICAL RIGHT SHIFT
             4'b1011: begin// ARITHMETIC RIGHT SHIFT 
                 Var = A[15];
                 C = A>>1;
                 C[15] = Var;
                 Var = 0;
             end
             4'b1100: begin// ROTATE RIGHT
                 Var = A[0];
                 C = A>>1;
                 C[15] = Var;
                 Var = 0;
             end
 
             4'b1101: C = A<<1; // LOGICAL LEFT SHIFT
             4'b1110: C = A<<1; // ARITHMETIC LEFT SHIFT
             4'b1111: begin // ROTATE LEFT
                 Var = A[15];
                 C = A<<1;
                 C[0] = Var;
                 Var = 0;
             end
 
         endcase
     end
 endmodule
