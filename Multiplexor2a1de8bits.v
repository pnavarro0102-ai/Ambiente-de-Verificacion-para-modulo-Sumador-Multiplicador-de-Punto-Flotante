////////////////////////////////////////////////////////////////////
//
//  Multiplexor2a1de8bits.v
//
//  Este modulo sirve como multiplexor de 8 bits
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

 module Multiplexor2a1de8bits (A, B, SEL, OUT);
    
    input [7:0] A, B;
    input SEL;
    output reg [7:0] OUT;

    always @(A or B or SEL) begin
        if (SEL)
            OUT = A;
        else 
            OUT = B;
    end

 endmodule

////////////////////////////////////////////////////////////////////