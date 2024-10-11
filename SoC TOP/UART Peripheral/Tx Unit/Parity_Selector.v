//this module is to choose even or odd parity bit
module Parity_Selector (
    input baud_clk, rst,
    input [7:0] data_in,
    input parity_sel,
    output reg parity_bit
);
    localparam EVEN = 0, //even parity
            ODD  = 1; //odd parity
    wire odd_or_even ; // internal signal to determone the no. of ones whether it's odd or even
    assign odd_or_even = ^(data_in) ; // if 1 it's odd else it's even
    //output logic
    always @(*) begin
        case (parity_sel)
            EVEN: begin
                if (odd_or_even) //it's an odd no. of ones so we need another 1 to make it even
                    parity_bit = 1;
                else
                    parity_bit = 0;
            end 
            ODD: begin
                if (odd_or_even) //it's an even no. of ones so we need one more 0 to make it odd
                    parity_bit = 0;
                else
                    parity_bit = 1;
            end
            default: begin // default is even parity
                if (odd_or_even) //it's an odd no. of ones so we need another 1 to make it even
                    parity_bit = 1;
                else
                    parity_bit = 0;
            end  
        endcase
    end   
endmodule