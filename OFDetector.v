////////////////////////////////////////////////////////////////////
//
//  OFDetector.v
//
//  Este modulo sirve como detector de overflow o underflow
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

module OFDetector (EXP, FRAC, OVF, UNF);
    
    input [8:0] EXP;
    input  [22:0] FRAC;
    output OVF, UNF;

 	wire bit8   = EXP[8];
    wire [7:0] lsb = EXP[7:0];

  
    assign OVF = (!bit8 && (lsb > 8'd254)) ||   
                 ( bit8 && (lsb < 8'd128));     

    assign UNF = ( bit8 && (lsb >= 8'd128)) ||  
                 ((EXP == 9'd0) && (FRAC != 0)); 

endmodule

////////////////////////////////////////////////////////////////////