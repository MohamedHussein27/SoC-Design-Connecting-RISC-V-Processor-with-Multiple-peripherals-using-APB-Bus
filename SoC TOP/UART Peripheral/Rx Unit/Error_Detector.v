// this combinational module is to generate the possible errors in the UART Protocol 
module Error_Detector (
    input rst,
    input [11:0] data_in,
    output reg OE, BE, FE,
    output PUARTERR // modified for SoC
);
    always @(*) begin
        if (~rst) begin
            OE <= 1'b0;
            BE <= 1'b0;
            FE <= 1'b0;
        end
        else begin // we only care about the error bits not the data and parity bits
            OE = data_in[9]; // refer to Rx_FIFO to know why data_in[9]
            BE = data_in[10];// refer to Rx_FIFO to know why data_in[10]
            FE = data_in[11];// refer to Rx_FIFO to know why data_in[11]
        end
    end
    // slave erroe
    assign PUARTERR = OE || BE || FE;
endmodule