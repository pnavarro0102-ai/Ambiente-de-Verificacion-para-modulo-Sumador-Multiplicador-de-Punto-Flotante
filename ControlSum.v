////////////////////////////////////////////////////////////////////
//
//  ControlSum.v
//
//  Este modulo sirve como control de la suma.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

`include "Comparador.v"
`include "Multiplexor2a1de8bits.v"
`include "Multiplexor2a1de23bits.v"
`include "ShiftRight24bits.v"
`include "Big_ALU.v"

module ControlSum (CLK, RST, ENA,
                   SIGN_A, EXP_A, FRA_A, 
                   SIGN_B, EXP_B, FRA_B, 
                   SIGN_OUT, EXP_OUT, FRA_OUT);
    
    input CLK, RST, ENA;
    input SIGN_A;
    input [7:0] EXP_A;
    input [22:0] FRA_A;

    input SIGN_B;
    input [7:0] EXP_B;
    input [22:0] FRA_B;

    output wire SIGN_OUT;
    output wire [7:0] EXP_OUT;
    output wire [22:0] FRA_OUT;

    //Comparar exponentes
        wire SWAP;
        wire [7:0] DIF;
        Comparador comp (EXP_A, EXP_B, FRA_A, FRA_B, DIF, SWAP);
    
    //Multiplexacion de exponentes y mantisas
        wire [7:0] exp_max, exp_min;
        Multiplexor2a1de8bits M1 (EXP_B, EXP_A, SWAP, exp_max);
        Multiplexor2a1de8bits M2 (EXP_A, EXP_B, SWAP, exp_min);

        wire [22:0] sel_max, sel_min;
        Multiplexor2a1de23bits M3 (FRA_B, FRA_A, SWAP, sel_max);
        Multiplexor2a1de23bits M4 (FRA_A, FRA_B, SWAP, sel_min);

        wire [23:0] frac_max = {1'b1, sel_max};
        wire [23:0] frac_min = {1'b1, sel_min};

    //Shift a la mantisa
        wire [23:0] frac_min_ali;
        ShiftRight24bits SR (CLK, RST, ENA, frac_min, DIF[4:0], frac_min_ali);

    //Suma o resta de mantisas
        wire        op_sub = SIGN_A ^ SIGN_B;
        wire [23:0] sum_pre;
        wire        carry;
        Big_ALU ALU (frac_max, frac_min_ali, op_sub, CLK, ENA, RST, carry, sum_pre);

    //Normalización
        wire [24:0] raw_sum = {carry, sum_pre};  
        wire need_sr = carry;
        wire need_sl = ~carry & ~raw_sum[23];

        wire [24:0] norm25_1 = need_sr ? (raw_sum >> 1) : raw_sum;
        wire [24:0] norm25_2 = need_sl ? (norm25_1 << 1) : norm25_1;
        wire [23:0] norm24   = norm25_2[23:0];

        wire is_zero = (norm24 == 24'd0);

        assign SIGN_OUT = is_zero ? 1'b0
                                : (SWAP ? SIGN_B : SIGN_A);

        assign EXP_OUT  = is_zero ? 8'd0
                                : exp_max + (need_sr ? 1 : 0) - (need_sl ? 1 : 0);

        assign FRA_OUT  = is_zero ? 23'd0
                                : norm24[22:0];

endmodule

////////////////////////////////////////////////////////////////////