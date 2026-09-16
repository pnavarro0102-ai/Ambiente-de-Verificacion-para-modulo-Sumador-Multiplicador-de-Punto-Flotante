////////////////////////////////////////////////////////////////////
//
//  Modulo_Principal.v
//
//  Este modulo sirve como modulo pricipal del sumador y multiplicador.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

`include "ControlSum.v"
`include "ControlMult.v"
`include "Multiplexor2a1de32bits.v"

module Modulo_Principal (CLK, RST, ENA, A, B, SEL_OP, OUT, EXC);
    
    parameter ENABLE_EXC = 1;

    input CLK, RST, ENA;
    input [31:0] A, B;
    input SEL_OP;

    output wire [31:0] OUT;
    output wire [1:0] EXC;
    
    //Desconponer operandos
        wire        SIGN_A = A[31];
        wire [7:0]  EXP_A  = A[30:23];
        wire [22:0] MANT_A = A[22:0];

        wire        SIGN_B = B[31];
        wire [7:0]  EXP_B  = B[30:23];
        wire [22:0] MANT_B = B[22:0];

    wire [23:0] MANT_A24 = (EXP_A == 8'd0) ? {1'b0, MANT_A} : {1'b1, MANT_A};
    wire [23:0] MANT_B24 = (EXP_B == 8'd0) ? {1'b0, MANT_B} : {1'b1, MANT_B};

    //Suma y resta
        wire        SIGN_ADD;
        wire [7:0]  EXP_ADD;
        wire [22:0] MANT_ADD;

        ControlSum SUM (CLK, RST, ENA,
                        SIGN_A, EXP_A, MANT_A, 
                        SIGN_B, EXP_B, MANT_B, 
                        SIGN_ADD, EXP_ADD, MANT_ADD);

        wire [31:0] RESULT_ADD = {SIGN_ADD, EXP_ADD, MANT_ADD};

    //Multiplicacion 
        wire        SIGN_MUL;
        wire [8:0]  EXP_MUL;   
        wire [22:0] MANT_MUL;
        wire [1:0]  EXC_MUL;

        ControlMult MULT (CLK, RST, ENA, 
                          SIGN_A, EXP_A, MANT_A24, 
                          SIGN_B, EXP_B, MANT_B24,
                          SIGN_MUL, EXP_MUL, MANT_MUL, EXC_MUL);

        wire [8:0] e = EXP_MUL;            // atajo

        wire under_mul =  e[8] &  (e[7:0] >= 8'd128);     
        wire over_mul  = (~e[8] & (e[7:0] >  8'd254)) |   
                         ( e[8] &  (e[7:0] <  8'd128));   

        wire [7:0]  exp_sat   = over_mul  ? 8'hFF :
                                under_mul ? 8'd0  :
                                            e[7:0];

        wire [22:0] frac_sat  = (over_mul | under_mul) ? 23'd0 : MANT_MUL;
        wire sign_sat  = under_mul ? SIGN_MUL : SIGN_MUL;

        wire [31:0] RESULT_MUL = {sign_sat, exp_sat, frac_sat};
    //Escogencia de operacion 
        Multiplexor2a1de32bits MUX (RESULT_ADD, RESULT_MUL, SEL_OP, OUT);

    generate
        if (ENABLE_EXC) begin : g_exc
            assign EXC = EXC_MUL;    // solo la multiplicación genera EXC
        end else begin
            assign EXC = 2'b00;
        end
    endgenerate

endmodule

////////////////////////////////////////////////////////////////////
