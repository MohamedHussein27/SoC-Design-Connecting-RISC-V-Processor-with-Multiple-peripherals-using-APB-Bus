module SoC_tb ();
    logic clk, rst;
    // UART prephral
    logic [8:0] data_out; // parallel output data, the output data increaced one bit
    logic OE, BE, FE ; // Error output signals

    SoC dut (.*);

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    // stimulus
    initial begin
        rst = 0;
        #20;
        rst = 1;
        #600000;
        $stop;
    end
endmodule