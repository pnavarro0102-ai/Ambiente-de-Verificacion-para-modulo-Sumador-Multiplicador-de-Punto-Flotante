////////////////////////////////////////////////////////////////////
//
//  Big_ALU.v
//
//  Este modulo sirve como la ALU de 24 bits del modulo.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

module Big_ALU (A, B, OP, CLK, ENA, RST, C, OUT);
    
  input [23:0] A, B;
  input OP;
  input ENA, CLK, RST;
  output wire [23:0] OUT;
  output wire C;

  wire [24:0] result_comb = OP

  ? ({1'b0, A} - {1'b0, B}): ({1'b0, A} + {1'b0, B});
  
  assign {C, OUT} = result_comb;

endmodule

////////////////////////////////////////////////////////////////////