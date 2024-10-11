// this module's primary purpose is to choose which prephral will be used according to the address
module APB_Decoder (
    input rst, clk, PSEL , PENABLE , PWRITE ,
    input [31:0] PADDR , PWDATA ,
    input [3:0] PSTRB ,
    input PREADY_W, PREADY_R, // PREADY signal but one for write and one for read
    // signals for UART
    input PUARTERR, // PSLVERR signal but for UART
    input Rx_ready_APB, // flag to state that the FIFO is ready for receiving from Tx_FIFO so we will use it to control our start_Tx signal
    output reg start_Tx, // start bit for transmission (active low) we will control it using Rx_ready_APB as we are not able to manually feed it
    output reg write_uart, read_uart, parity_sel, 
    output reg [1:0] baud_selector, 
    output reg [7:0] data_out_to_uart,
    // prephral READY signal
    output PREADY, PSLVERR,
    output new_instruction_Tx, new_instruction_Rx// a flag to state the the upcoming instruction is new so we will reset the serial counter in Tx_FIFO and Rx_FIFO 
);
    reg lock; // internal flag to make the start_Tx signal triggered only once in each read process
    always @(posedge clk) begin
        if(~rst || PREADY_W /*|| PREADY_R*/) begin
            write_uart = 0;
            read_uart = 0;
            //data_out_to_uart = 0;
            start_Tx = 1;
            parity_sel = 0; // default signals for UART
            baud_selector = 1;
        end
        // choose UART (address 1000 to address 2000) 
        else if (PSEL && PENABLE && PADDR >= 1000 && PADDR < 2000) begin
            if (PWRITE) begin // writing
                write_uart = PWRITE;
                data_out_to_uart = PWDATA[7:0]; // as UART takes data byte by byte
            end
            else begin
                if (Rx_ready_APB) begin
                    start_Tx = 1;
                    read_uart = 1; // we are sure that there is data in Rx_FIFO so we can receive
                    lock = 1;
                end
                else if (!PREADY_R) begin
                    start_Tx = 0; // serialize data to Rx_FIFO until it's ready
                    //lock = 1;
                end
                else begin
                    start_Tx = 1;
                    read_uart = 0;
                    lock = 0;
                end
            end     
        end
    end
    // PREADY signal and PSLVERR signal for UART
    assign PREADY = PREADY_W || PREADY_R; 
    assign new_instruction_Tx = PREADY_R;
    assign new_instruction_Rx = PREADY_R;
    assign PSLVERR = PUARTERR;
endmodule