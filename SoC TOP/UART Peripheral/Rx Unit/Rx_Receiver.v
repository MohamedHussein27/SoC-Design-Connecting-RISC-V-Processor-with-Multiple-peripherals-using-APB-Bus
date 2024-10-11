// this module is used to getting the desired data from the Rx_FIFO's output data (last stage)
module Rx_Receiver (
    input baud_clk, rst,
    input [11:0] data_in, // data from the Rx_FIFO
    input RxFE, receive, // receive signal is the receive order in Rx_FIFO
    output reg PREADY_R, // modified for SoC 
    output receive_order,
    output reg [8:0] data_out  // 9 bits output data as we included the parity bit 
);
    reg flag;
    assign receive_order = receive;
    reg RxFE_reg; // as we want this signal to be registed to get the last element of the Rx_FIFO
    always @(posedge baud_clk) begin
        RxFE_reg <= RxFE;
    end
    always @(*) begin
        if (~rst) 
            data_out <= 0;
        else begin
            if (receive && ~RxFE_reg) begin  // when receive order comes and the FIFO is not empty at this time
                data_out <= data_in[8:0];  // as we only care for the data and parity bit not the error bits
            end
        end
    end    
    always @(posedge baud_clk) begin
        if (receive && ~RxFE_reg) begin 
            flag <= 1;
            PREADY_R <= flag;
        end
        else begin
            flag <= 0;
            PREADY_R <= flag;
        end
    end
endmodule