////////////////////////////////////////////////////////////////////
//
//  Multiplexor2a1de23bits.v
//
//  Este modulo sirve como multiplexor de 23 bits
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

 module Multiplexor2a1de23bits (A, B, SEL, OUT);
    
 	input [22:0] A, B;
    input SEL;
    output reg [22:0] OUT;

    always @(A or B or SEL) begin
    	if (SEL)
            OUT = A;
        else 
            OUT = B;
    end

 endmodule

////////////////////////////////////////////////////////////////////