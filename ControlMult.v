////////////////////////////////////////////////////////////////////
//
//  ControlMult.v
//
//  Este modulo sirve como control de la multiplicación.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

`include "ExpSum.v"
`include "Mult.v"
`include "DerInc.v"
`include "Normalizador.v"
`include "OFDetector.v"
`include "Signo.v"

module ControlMult (CLK, RST, ENA, 
                    SIGN_A, EXP_A, FRA_A, 
                    SIGN_B, EXP_B, FRA_B,
                    SIGNM_R, EXP_R, FRAC_R, EXC);

    input CLK, RST, ENA;
    input SIGN_A, SIGN_B;
    input [7:0] EXP_A, EXP_B;
    input [23:0] FRA_A, FRA_B;
    output SIGNM_R;
    output [8:0]  EXP_R;
    output [22:0] FRAC_R;
    output [1:0] EXC;

    wire [8:0] exp_sum;
    ExpSum uExp (EXP_A, EXP_B, exp_sum);

    wire [47:0] prod;
    Mult uMult (FRA_A, FRA_B, prod);

    wire [22:0] frac_int;
    wire [8:0] exp_int;
    Normalizador uNorm (CLK, RST, ENA, prod, exp_sum, frac_int, exp_int);

    assign FRAC_R = frac_int;
    assign EXP_R  = exp_int;

    wire ovf, unf;
    OFDetector uOF (EXP_R, FRAC_R, ovf, unf);

    Signo uSign (SIGN_A, SIGN_B, ovf, unf, SIGNM_R, EXC);
    
endmodule

////////////////////////////////////////////////////////////////////