// this module is including all transmission modules instantiated 
module Tx_Unit #(
    parameter FIFO_WIDTH_T = 9 , // 8 bits for data and one bit for parity
    parameter FIFO_DEPTH_T = 16
) (
    input baud_clk, rst,
    input write, // command to start writing in Tx_FIFO
    input [7:0] data_in, // external system input data
    input parity_sel, 
    input start_Tx, // to start the transaction between the two FIFOs 
    input Rx_ready, // flag from Rx_FIFO to state that the FIFO is ready for receiving from Tx_FIFO
    input new_instruction_Tx, // a flag to state the the upcoming instruction is new so we will reset the serial counter in the Tx_FIFO
    output data_out, // serial data from the Tx_FIFO (PISO)
    output PREADY_W   // flag to state that the FIFO stored the data ( for APB Decoder)
);
    // internal wires
    //signals for Tx_Transmitter and Tx_FIFO
    wire TxFF; 
    wire start_Rx;
    wire [7:0] data_Trans_FIFO; // to connect the data out from the Tx_Transmitter with the input data in Tx_FIFO
    //signals for Parity_Selector and Tx_FIFO
    wire parity_bit; 




    //****************** Tx_Transmitter ****************\\
    Tx_Transmitter transmitter(
        .baud_clk(baud_clk),
        .rst(rst),
        .write(write),
        .data_in(data_in),
        .TxFF(TxFF),
        .start_Rx(start_Rx),
        .data_out(data_Trans_FIFO)
    );


    //****************** Tx_FIFO ****************\\
    Tx_FIFO #(
        FIFO_WIDTH_T,
        FIFO_DEPTH_T 
    ) Tx_fifo (
        .baud_clk(baud_clk),
        .rst(rst),
        .start_Tx(start_Tx),
        .start_Rx(start_Rx),
        .parity_bit(parity_bit),
        .data_in(data_Trans_FIFO),
        .new_instruction_Tx(new_instruction_Tx),
        .Rx_ready(Rx_ready),
        .PREADY_W(PREADY_W),
        .TxFF(TxFF),
        .data_out(data_out)
    );


     //****************** Parity_Selector ****************\\
     Parity_Selector parity_selector(
        .baud_clk(baud_clk),
        .rst(rst),
        .data_in(data_in),
        .parity_sel(parity_sel),
        .parity_bit(parity_bit)
     );    
endmodule