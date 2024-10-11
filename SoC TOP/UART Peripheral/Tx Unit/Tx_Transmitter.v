//this module is made to send data with hte system clk rate
module Tx_Transmitter (
    input baud_clk,  //clock for the entire system
    input rst,
    input write, // command to start writing in Tx_FIFO
    input TxFF, // input signal from TxFIFO 
    input [7:0] data_in, //input data from external system
    output reg [7:0] data_out, // parallel data
    output start_Rx //to let the Tx_FIFO start receiving data from this module
);
    //reg new;    // to compare between next and previous data so as if it's new then it will be stored in the FIFO
    //wire [7:0] next; // to get the next data
    //reg [7:0] prev;  // to get the previous data
    //assign next = data_in;
    always @(posedge baud_clk) begin
        if(~rst)
            data_out <= 0;
        else if(~TxFF) begin//the FIFO is not full yet
            data_out <= data_in ;  
            //prev <= data_in ;
        end   
    end
    assign start_Rx = (data_out !== 8'hxx) ? write : 0;
    /*always @(*) begin
        if (next !== prev) //comparison
            new = 1;
        else
            new = 0;
    end
    assign start_Rx = (!new || !rst) ? 0 : 1; //if there is new data then the FIFO starts receiving*/
endmodule