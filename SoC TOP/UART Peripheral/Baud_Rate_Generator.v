// this module is to generate the baud clock which will be used in out UART Protocol
module Baud_Rate_Generator #(
    parameter CLK_FREQ = 50_000_000, // System clock frequency in Hz
    parameter SAMPLE = 16     // Most common oversampling in UART 
) (
    input SysClk,       // System clock input
    input rst,        // Active high reset signal
    input [1:0] baud_selector,     // Selector to choose the BAUD rate
    output reg  baud_clk     // Output baud tick signal
);

    
    localparam  BAUD48 = 0,   // 4800 BAUD rate
                BAUD96 = 1,   // 9600 BAUD rate
                BAUD576 = 2,  // 57600 BAUD rate
                BAUD1152 =  3; // 115200 BAUD rate
    
    integer DIVISOR = 0 ;
    // Using 16x oversampling for more accurate baud rate generation
    // Calculate the clock divisor needed to generate the baud rate
    always @(*) begin
        case (baud_selector)
            BAUD48: DIVISOR = CLK_FREQ/(4800*SAMPLE) ;
            BAUD96: DIVISOR = CLK_FREQ/(9600*SAMPLE) ;
            BAUD576: DIVISOR = CLK_FREQ/(57600*SAMPLE) ;
            BAUD1152: DIVISOR = CLK_FREQ/(115200*SAMPLE) ;  
            default: DIVISOR = CLK_FREQ/(9600*SAMPLE) ; // Default is 9600 as it's the most common
        endcase
    end

    reg [15:0] counter = 0;  // 16-bit counter

    always @(posedge SysClk or negedge rst) begin
        if (~rst) begin
            counter <= 0;
            baud_clk <= 0;
        end else begin
            if (counter == DIVISOR - 1) begin // -1 as the counter starts from 0
                baud_clk <= ~ baud_clk;    // Toggle the clk 
                counter <= 0;      // Reset counter
            end 
            else 
                counter <= counter + 1;
        end
    end
endmodule
