////////////////////////////////////////////////////////////////////
//
//  Comparador.v
//
//  Este modulo sirve como comparador de exponentes.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

module Comparador (EXP_A, EXP_B, FRA_A, FRA_B, DIF, SWAP);
  
  input  [7:0] EXP_A, EXP_B;
  input  [22:0] FRA_A, FRA_B;
  output wire [7:0] DIF;
  output wire SWAP;

    wire swap_exp = (EXP_B > EXP_A);

    wire swap_eq  = (EXP_B == EXP_A) && (FRA_B > FRA_A);

    assign SWAP = swap_exp | swap_eq;

    assign DIF  = SWAP ? (EXP_B - EXP_A) : (EXP_A - EXP_B);
    
endmodule

////////////////////////////////////////////////////////////////////