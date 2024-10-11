// this is PISO module (parallel in serial out)
module Tx_FIFO #(
    parameter FIFO_WIDTH_T = 9 , // 8 bits for data and one bit for parity
    parameter FIFO_DEPTH_T = 16
) (
    input baud_clk ,
    input rst,
    input start_Tx,  // start bit for transmission (active low)
    input start_Rx, // FIFO starts receiving
    input parity_bit, 
    input [7:0] data_in, // parallel data
    input Rx_ready, // flag from Rx_FIFO to state that the FIFO is ready for receiving from Tx_FIFO
    input new_instruction_Tx, // a flag to state the the upcoming instruction is new so we will reset the serial counter in the Tx_FIFO
    output reg PREADY_W, // flag to state that the FIFO stored the data ( for APB Decoder)
    output reg TxFF, // FIFO full 
    output reg data_out // serial data
);

    reg [FIFO_WIDTH_T-1:0] Tx_FIFO [FIFO_DEPTH_T-1:0] ; //declaring Tx_FIFO
    // internal signals
    reg TxFE ;// FIFO empty
    reg active_flag ; //flag to indicate that the Tx_FIFO is sending data
    reg done_transmission ; //flag to indicate that the Tx_FIFO has done sending data
    reg [3:0] serial_counter ; //internal signal to send the serialized data to Rx_FIFO
    reg [3:0] filling_counter ; // internal signal to fill the Tx_FIFO with received data
    reg [3:0] sending_counter ; //internal signal to select data will be sent to the Rx_FIFO
    reg [FIFO_WIDTH_T-1:0] bus  ;// internal signal to take the data from Tx_FIFO and send it to Rx_FIFO to prevent operations directly on the memory  
    reg waiting = 1;   // flag to indicate that we are in WAIT state
    //FSM
    localparam IDLE = 0,
            RECEIVE = 1, //state for receiving data from the transmitter
            WAIT = 2, //state for waiting if the next and previous data are same
            ACTIVE = 3,
            RESET = 4; // state for resetting the serial counter (modified for SoC)

    reg [2:0] ns , cs ; // modified for SoC
    //state memory
    always @(posedge baud_clk or negedge rst) begin
        if (~rst)
            cs <= IDLE;
        else
            cs <= ns;
    end
    //next state logic
    always @(*) begin
        case (cs)
            IDLE : begin
                if(start_Rx)
                    ns = RECEIVE;
                else
                    ns = IDLE;
            end
            RECEIVE : begin
                if(~start_Tx)
                    ns = ACTIVE;
                //else if (start_Rx)
                    //ns = RECEIVE;
                else 
                    ns = WAIT;
            end
            //LATENCY : ns = WAIT;
            WAIT : begin
                if(~start_Tx)
                    ns = ACTIVE;
                else if (start_Rx)
                    ns = RECEIVE;
                else 
                    ns = WAIT;
            end
            ACTIVE : begin
                if(serial_counter == 9)
                    ns = WAIT;
                else if (new_instruction_Tx)
                    ns = RESET;
                else
                    ns = ACTIVE;
            end
            RESET : begin
                if(~start_Tx)
                    ns = ACTIVE;
                else if (start_Rx)
                    ns = RECEIVE;
                else 
                    ns = WAIT;
            end
        endcase
    end

    //output logic
    always @(posedge baud_clk) begin
        if(cs == IDLE) begin
            data_out <= 1; // as the start bit in the Rx_FIFO is zero so it doesn't start receiving
            filling_counter <= 0;
            serial_counter <= 15; // to send the start bit to Rx_FIFO
            sending_counter <= 0;
            TxFF <= 0;
            TxFE <= 1;
            active_flag <= 0;
            done_transmission <= 0;
            PREADY_W <= 0;
            waiting <= 0;
        end
        // this state is like writing process in regular FIFO
        else if(cs == RECEIVE) begin
            if (~TxFF) begin
                Tx_FIFO[filling_counter] <= {parity_bit,data_in};
                PREADY_W <= 1; // FIFO storeed data (APB decoder)
                TxFE <= 0; // FIFO is not empty
                waiting <= 0;
                filling_counter <= filling_counter + 1;
                if ((filling_counter + 1 == sending_counter) || ((filling_counter == (FIFO_DEPTH_T - 1)) && (sending_counter == 0)))
                    TxFF <= 1; // FIFO is full
            end
        end
        else if (cs == WAIT) begin
            waiting <= 1;
            PREADY_W <= 0;
        end
        // this state is like reading process in regular FIFO
        else if(cs == ACTIVE) begin
            if (~TxFE || serial_counter != 15) begin
                TxFF <= 0; // not full
                bus <= Tx_FIFO[sending_counter];
                waiting <= 0;
                PREADY_W <= 0;
                if (!Rx_ready && done_transmission)  // this statement is to avoid beginning another transfe unless the Rx_FIFO is ready, I used done transmission flag to make sure data is transmitted once at least
                    serial_counter <= 15;
                else if (serial_counter == 15) begin // just at the beggining
                    data_out <= 0; // the start bit to start the receiving on Rx_FIFO
                    serial_counter <= serial_counter + 1;
                end
                else begin
                    if (serial_counter == 9) begin
                        done_transmission <= 1; // it's like the end bit
                        data_out <= 1; // end bit
                        active_flag <= 0; // it's not sending anymore
                        serial_counter = 15; // resetting the serial counter again
                        sending_counter <= sending_counter + 1; //incerement the sending counter to send from another place at the next sending process
                    end
                    else begin
                        data_out <= bus[serial_counter]; // to send bit bit 
                        serial_counter <= serial_counter + 1; // we will send the start bit then from the least bit to the most bit and then the parity bit
                        active_flag <= 1; //as the Tx_FIFO is now sending data
                        done_transmission <= 0; // sending not completed yet
                    end
                    if ((sending_counter == filling_counter) /*modified for SoC*/ || ((sending_counter == (FIFO_DEPTH_T-1)) && (filling_counter == 0)))
                        TxFE = 1; // empty
                end
            end
        end
        else if (cs == RESET) begin
            serial_counter = 15;
            data_out <= 1;
        end
    end
endmodule