////////////////////////////////////////////////////////////////////
//
//  DerInc.v
//
//  Este modulo sirve como modulo de decremento e incremento.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

module DerInc (EXP_IN, INC, EXP_OUT);
    
    input [7:0] EXP_IN;
    input INC;                  //Si INC=1, EXP_OUT = EXP_IN + 1; si INC=0, EXP_OUT = EXP_IN - 1
    output wire [7:0] EXP_OUT;

    assign EXP_OUT = INC ? (EXP_IN + 1) : (EXP_IN - 1);

endmodule

////////////////////////////////////////////////////////////////////