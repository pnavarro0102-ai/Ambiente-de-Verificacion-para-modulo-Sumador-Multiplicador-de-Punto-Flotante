////////////////////////////////////////////////////////////////////
//
//  ShiftRight24bits.v
//
//  Este modulo sirve como shift right de 24 bits.
//                
//  Pablo Navarro y Vladimir Gonzales
//
////////////////////////////////////////////////////////////////////

module ShiftRight24bits (CLK, RST, ENA, DATA, DESP, OUT);
    
    input CLK, RST;
    input ENA;
    input  [23:0] DATA;
    input  [4:0] DESP;
    output reg [23:0] OUT;

    always @(posedge CLK or posedge RST) begin
        if (RST) begin
            OUT <= 24'd0;
        end else if (ENA) begin
            OUT <= DATA >> DESP;
        end
    end

endmodule
   
////////////////////////////////////////////////////////////////////