// this is SIPO module ( Serial in Parallel out )
module Rx_FIFO #(
    parameter FIFO_WIDTH_R = 12 , // 8 bits for data, one for parity and three for errors
    parameter FIFO_DEPTH_R = 16
) (
    input baud_clk, rst,
    input data_in,  // serial input data
    input receive_order, // other system is requesting for receive data
    input new_instruction_Rx, // a flag to state the the upcoming instruction is new so we will reset the serial counter in Rx_FIFO 
    output reg RxFE, // FIFO empty
    output reg Rx_ready, // flag to state that the FIFO is ready for receiving from Tx_FIFO
    output reg Rx_ready_APB, // flag for APB to indicate the data now is in Rx_FIFO
    output reg [FIFO_WIDTH_R-1:0] data_out // parallel output data
);

    reg [FIFO_WIDTH_R-1:0] Rx_FIFO [FIFO_DEPTH_R-1:0] ; //declaring Rx_FIFO
    // internal signals
    reg RxFF ; // FIFO full
    reg transfer_flag ; // data is changing from serial to parallel
    reg done_receiving ; // flag to indicate that the data is loaded in the R_bus internal signal
    reg [8:0] R_bus; // internal signal to load data in and then assign it to the Rx_FIFO
    reg [3:0] serial_counter ; // internal signal to fi;; R_bus with serial data input
    reg [3:0] filling_counter ; // internal signal to fill the Tx_FIFO with received data
    reg [3:0] sending_counter ; //internal signal to select data will be sent to the Rx_FIFO
    reg [1:0] break_counter; // counter for break error
    reg FE, BE, OE; // UART Errors (Frame Error, Break Error, Overrun Error)


    //FSM
    localparam  IDLE = 0,
                ACTIVE = 1,
                FILLING = 2, // state for loading the Rx_FIFO with data
                READY = 3, // state to announce that the Rx_FIFO is ready for more data
                TRANSMITTING = 4, // state for sending the data to be received
                WAIT = 5; // state to wait nothing more and nothing less

    reg [2:0] ns , cs;
    // state memory
    always @(posedge baud_clk or negedge rst) begin
        if (~rst)
            cs <= IDLE;
        else
            cs <= ns;
    end
    // next state logic
    always @(*) begin
        case (cs)
            IDLE: begin
                if (data_in == 0) // start bit is received
                    ns <= ACTIVE;
                else
                    ns <= IDLE; 
            end
            ACTIVE: begin
                if (serial_counter == 9)
                    ns <= FILLING;
                else
                    ns <= ACTIVE;
            end
            FILLING: ns <= READY;
            READY: begin
                if (receive_order)
                    ns <= TRANSMITTING;
                else if (data_in == 0)
                    ns <= ACTIVE;
                else
                    ns <= READY;
            end
            TRANSMITTING: begin
                if (receive_order)
                    ns <= TRANSMITTING;
                else if (data_in == 0)
                    ns <= ACTIVE;
                else 
                    ns <= WAIT; // was ns <= READY (modified for SoC)
            end
            WAIT: begin
                if (receive_order)
                    ns <= TRANSMITTING;
                else if (new_instruction_Rx)
                    ns <= WAIT;
                else if (data_in == 0)
                    ns <= ACTIVE;
                else 
                    ns <= WAIT; 
            end
        endcase
    end
    // output logic
    always @(posedge baud_clk) begin
        if (cs == IDLE) begin
            RxFE <= 1; // FIFO is empty
            RxFF <= 0; // FIFO is not full
            serial_counter <= 0;
            filling_counter <= 0;
            sending_counter <= 0;
            break_counter <= 0;
            transfer_flag <= 0;
            done_receiving <= 0;
            Rx_ready <= 0;
            Rx_ready_APB <= 0;
            FE <= 0; // No Frame Error
            BE <= 0; // No Break Error
            OE <= 0; // No Overrun Error
        end
        else if (cs == ACTIVE) begin
            Rx_ready <= 0;
            Rx_ready_APB <= 0;
            if (~RxFF) begin // if the Rx_FIFO is not full then begin receiving data
                if (serial_counter == 9) begin
                    done_receiving <= 1;
                    transfer_flag <= 0;
                    serial_counter <= 0; // resetting counter again
                    if (data_in != 1) // data_in should be equal to 1 as it's the stop bit
                        FE <= 1; // Framing Error occurs when the stop bit is not correct
                end
                else begin
                    R_bus[serial_counter] <= data_in;
                    serial_counter <= serial_counter + 1;
                    transfer_flag <= 1;
                    done_receiving <= 0;
                end
            end
            else
                OE <= 1; // Overrun Error happens when the Rx_FIFO is full and more input frames are arriving at the receiver.          
        end
        // this state is like writing process in regular FIFO
        else if (cs == FILLING) begin
            Rx_ready <= 0;
            Rx_ready_APB <= 0;
            if (break_counter == 3)
                BE <= 1; // Break Error occurs when the input is held low for more than a frame (3 frames in our case)
            else if (R_bus == 0) 
                break_counter <= break_counter + 1;
            else begin
                if (~RxFF) begin
                    Rx_FIFO[filling_counter] <= {FE, BE, OE, R_bus}; // the Rx_FIFO has the data, parit bit, and Errors
                    RxFE <= 0; // FIFO is not empty
                    filling_counter <= filling_counter + 1;
                    if ((filling_counter + 1 == sending_counter) || ((filling_counter == (FIFO_DEPTH_R - 1)) && (sending_counter == 0)))
                        RxFF <= 1; // FIFO is full
                end
            end
        end
        else if (cs == READY) begin
            Rx_ready <= 1;
            Rx_ready_APB <= 1;
        end
        // this state is like reading process in regular FIFO
        else if (cs == TRANSMITTING) begin
            Rx_ready <= 0;
            Rx_ready_APB <= 0;
            if (receive_order && ~RxFE) begin
                data_out <= Rx_FIFO[sending_counter]; // sending data with error bits
                sending_counter <= sending_counter + 1;
                RxFF <= 0; // FIFO is not full
                if ((sending_counter + 1 == filling_counter) || ((sending_counter == (FIFO_DEPTH_R-1)) && (filling_counter == 0)))
                        RxFE = 1; // empty
            end
        end
        else if (cs == WAIT) begin
            Rx_ready <= 0;
            Rx_ready_APB <= 0;
            R_bus <= 0;
        end
    end
endmodule