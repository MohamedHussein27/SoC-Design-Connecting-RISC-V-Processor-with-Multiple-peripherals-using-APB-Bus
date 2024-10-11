// this module iis to connect between RISC_V Processor, RISC_APB_Wrapper, APB_Master, APB_Decoder, Prephrals(UART)
module SoC (
    input clk, rst,
    // UART prephral
    output [8:0] data_out, // parallel output data, the output data increaced one bit
    output OE, BE, FE // Error output signals
);
    // internal wires
    // signals between RISC_V_Wrapper and RISC_APB_Wrapper
    wire cancel_data_memory; // to cancel using data memory in case of lw or sw in prephral
    wire stop; // stop signal to stop the RISC_V PC from incerementing untill the data is sent or received using APB
    wire [31:0] Instr; // instruction from RISC-V
    wire [31:0] Reg1_out, Reg2_out; // output wires from RD1 and RD2 in Reg_File

    // signals between RISC_APB_Wrapper and APB_Master
    wire READY, SLVERR; // READY signal when high then we are back to the normal RISC-V cycle
    wire transfer; // to start using the APB master
    wire SWRITE;
    wire [31:0] SADDR, SWDATA;
    wire [3:0] SSTRB;

    // signals between APB_Master and APB_Decoder
    wire PSEL, PENABLE, PWRITE;
    wire [31:0] PADDR, PWDATA;
    wire [3:0] PSTRB;
    wire PREADY, PSLVERR;

    // signals between APB_Decoder and prephral(UART)
    wire PREADY_W, PREADY_R; // PREADY signal but one for write and one for read
    wire PUARTERR; // PSLVERR signal but for UART
    wire Rx_ready_APB; // flag to state that the FIFO is ready for receiving from Tx_FIFO so we will use it to control our start_Tx signal
    wire start_Tx; // start bit for transmission (active low) we will control it using Rx_ready_APB as we are not able to manually feed it
    wire write_uart, read_uart, parity_sel;
    wire [1:0] baud_selector;
    wire [7:0] data_out_to_uart;
    wire new_instruction_Tx, new_instruction_Rx;// a flag to state the the upcoming instruction is new so we will reset the serial counter in Tx_FIFO and Rx_FIFO 

    // RISC_V_Wrapper
    RISC_V_Wrapper risc_v_wrapper (
        .clk(clk),
        .rst(rst),
        .cancel_data_memory(cancel_data_memory),
        .stop(stop),
        .Instr(Instr),
        .Reg1_out(Reg1_out),
        .Reg2_out(Reg2_out)
    );

    // RISC_APB_Wrapper
    RISC_APB_Wrapper risc_apb_wrapper(
        .instruction(Instr),
        .RD1(Reg1_out),
        .RD2(Reg2_out),
        .clk(clk),
        .rst(rst),
        .READY(READY),
        .SLVERR(SLVERR),
        .stop(stop),
        .transfer(transfer),
        .SWRITE(SWRITE),
        .SADDR(SADDR),
        .SWDATA(SWDATA),
        .SSTRB(SSTRB),
        .cancel_data_memory(cancel_data_memory)
    );

    // APB_Master
    APB_Master apb_master(
        .SWRITE(SWRITE),
        .SADDR(SADDR),
        .SWDATA(SWDATA),
        .SSTRB(SSTRB),
        .transfer(transfer),
        .READY(READY),
        .SLVERR(SLVERR),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PSTRB(PSTRB),
        .PCLK(clk),
        .PRESETn(rst),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR)
    );

    // APB_Decoder
    APB_Decoder apb_decoder(
        .rst(rst),
        .clk(clk),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PSTRB(PSTRB),
        .PREADY_W(PREADY_W),
        .PREADY_R(PREADY_R),
        .PUARTERR(PUARTERR),
        .Rx_ready_APB(Rx_ready_APB),
        .start_Tx(start_Tx),
        .write_uart(write_uart),
        .read_uart(read_uart),
        .parity_sel(parity_sel),
        .baud_selector(baud_selector),
        .data_out_to_uart(data_out_to_uart),
        .PREADY(PREADY),
        .PSLVERR(PSLVERR),
        .new_instruction_Tx(new_instruction_Tx),
        .new_instruction_Rx(new_instruction_Rx)
    );

    // UART_TOP
    UART_TOP uart_top(
        .SysClk(clk),
        .rst(rst),
        .write(write_uart),
        .baud_selector(baud_selector),
        .data_in(data_out_to_uart),
        .parity_sel(parity_sel),
        .start_Tx(start_Tx),
        .receive(read_uart),
        .new_instruction_Tx(new_instruction_Tx),
        .new_instruction_Rx(new_instruction_Rx),
        .PREADY_W(PREADY_W),
        .PREADY_R(PREADY_R),
        .Rx_ready_APB(Rx_ready_APB),
        .data_out(data_out),
        .OE(OE),
        .BE(BE),
        .FE(FE),
        .PUARTERR(PUARTERR)
    );





















endmodule