////////////////////////////////////////////////////////////////////
//
//  Signo.v
//
//  Este modulo sirve como calculo de signo.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

module Signo (SIGNM_A, SIGNM_B, OVF, UNF, SIGNM_OUT, EXC);
    
    input  SIGNM_A, SIGNM_B;
    input   OVF, UNF;
    output SIGNM_OUT;
    output [1:0] EXC;         // 00=OK, 01=Under, 10=Over

    assign SIGNM_OUT = SIGNM_A ^ SIGNM_B;
    assign EXC     = OVF ? 2'b10 :
                     UNF ? 2'b01 : 2'b00;

endmodule

////////////////////////////////////////////////////////////////////