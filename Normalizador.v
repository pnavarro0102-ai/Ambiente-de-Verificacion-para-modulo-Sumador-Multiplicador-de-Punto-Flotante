////////////////////////////////////////////////////////////////////
//
//  Normalizador.v
//
//  Este modulo sirve como normalizador para la multiplicació.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////


module Normalizador (CLK, RST, ENA, PROD, EXP_IN, FRAC_OUT, EXP_O);
    
    input CLK, RST, ENA;
    input  [47:0] PROD;
    input  [8:0] EXP_IN;
    output [22:0] FRAC_OUT;
    output [8:0] EXP_O;

    wire [23:0] data24 = PROD[46:23];
    wire  needShift = PROD[47];

    wire [23:0] dataShift;
    ShiftRight24bits SH (CLK, RST, ENA, data24, {4'b0, needShift}, dataShift);

    wire [22:0] frac_noshift = data24   [22:0];
    wire [22:0] frac_shifted = dataShift[22:0];

    wire [22:0] frac_sel;
    Multiplexor2a1de23bits MUX_FRAC (frac_shifted, frac_noshift, needShift, frac_sel);

    wire [7:0] exp_plus1_8;
    DerInc INC1 (EXP_IN[7:0], 1'b1, exp_plus1_8);

    wire [7:0] exp_sel8;
    Multiplexor2a1de8bits MUX_EXP8 (exp_plus1_8, EXP_IN[7:0], needShift, exp_sel8);

    wire carry8 = needShift & (EXP_IN[7:0] == 8'hFF);
    wire [8:0] exp_norm = { (EXP_IN[8] | carry8), exp_sel8 };

    wire prod_is_zero = ~|PROD;

    assign FRAC_OUT = prod_is_zero ? 23'd0 : frac_sel;
    assign EXP_O    = prod_is_zero ? 9'd0  : exp_norm;


endmodule

////////////////////////////////////////////////////////////////////