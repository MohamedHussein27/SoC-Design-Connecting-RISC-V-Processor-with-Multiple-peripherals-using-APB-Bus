vlib work
vlog *.v
vsim -voptargs=+acc work.UART_tb -cover
add wave -position insertpoint  \
sim:/SoC_tb/clk \
sim:/SoC_tb/rst \
sim:/SoC_tb/data_out \
sim:/SoC_tb/OE \
sim:/SoC_tb/BE \
sim:/SoC_tb/FE
add wave -position insertpoint  \
sim:/SoC_tb/dut/risc_v_wrapper/S4_1/MEM_DEPTH \
sim:/SoC_tb/dut/risc_v_wrapper/S4_1/MEM_WIDTH \
sim:/SoC_tb/dut/risc_v_wrapper/S4_1/clk \
sim:/SoC_tb/dut/risc_v_wrapper/S4_1/rst \
sim:/SoC_tb/dut/risc_v_wrapper/S4_1/WE \
sim:/SoC_tb/dut/risc_v_wrapper/S4_1/A \
sim:/SoC_tb/dut/risc_v_wrapper/S4_1/WD \
sim:/SoC_tb/dut/risc_v_wrapper/S4_1/RD \
sim:/SoC_tb/dut/risc_v_wrapper/S4_1/RAM
add wave -position insertpoint  \
sim:/SoC_tb/dut/risc_apb_wrapper/IDLE \
sim:/SoC_tb/dut/risc_apb_wrapper/WAIT_W \
sim:/SoC_tb/dut/risc_apb_wrapper/WAIT_R \
sim:/SoC_tb/dut/risc_apb_wrapper/READY_WAIT \
sim:/SoC_tb/dut/risc_apb_wrapper/instruction \
sim:/SoC_tb/dut/risc_apb_wrapper/RD1 \
sim:/SoC_tb/dut/risc_apb_wrapper/RD2 \
sim:/SoC_tb/dut/risc_apb_wrapper/clk \
sim:/SoC_tb/dut/risc_apb_wrapper/rst \
sim:/SoC_tb/dut/risc_apb_wrapper/READY \
sim:/SoC_tb/dut/risc_apb_wrapper/SLVERR \
sim:/SoC_tb/dut/risc_apb_wrapper/stop \
sim:/SoC_tb/dut/risc_apb_wrapper/transfer \
sim:/SoC_tb/dut/risc_apb_wrapper/SWRITE \
sim:/SoC_tb/dut/risc_apb_wrapper/SADDR \
sim:/SoC_tb/dut/risc_apb_wrapper/SWDATA \
sim:/SoC_tb/dut/risc_apb_wrapper/SSTRB \
sim:/SoC_tb/dut/risc_apb_wrapper/cancel_data_memory \
sim:/SoC_tb/dut/risc_apb_wrapper/flag \
sim:/SoC_tb/dut/risc_apb_wrapper/cs \
sim:/SoC_tb/dut/risc_apb_wrapper/ns
add wave -position insertpoint  \
sim:/SoC_tb/dut/apb_decoder/rst \
sim:/SoC_tb/dut/apb_decoder/clk \
sim:/SoC_tb/dut/apb_decoder/PSEL \
sim:/SoC_tb/dut/apb_decoder/PENABLE \
sim:/SoC_tb/dut/apb_decoder/PWRITE \
sim:/SoC_tb/dut/apb_decoder/PADDR \
sim:/SoC_tb/dut/apb_decoder/PWDATA \
sim:/SoC_tb/dut/apb_decoder/PSTRB \
sim:/SoC_tb/dut/apb_decoder/PREADY_W \
sim:/SoC_tb/dut/apb_decoder/PREADY_R \
sim:/SoC_tb/dut/apb_decoder/PUARTERR \
sim:/SoC_tb/dut/apb_decoder/Rx_ready_APB \
sim:/SoC_tb/dut/apb_decoder/start_Tx \
sim:/SoC_tb/dut/apb_decoder/write_uart \
sim:/SoC_tb/dut/apb_decoder/read_uart \
sim:/SoC_tb/dut/apb_decoder/parity_sel \
sim:/SoC_tb/dut/apb_decoder/baud_selector \
sim:/SoC_tb/dut/apb_decoder/data_out_to_uart \
sim:/SoC_tb/dut/apb_decoder/PREADY \
sim:/SoC_tb/dut/apb_decoder/PSLVERR \
sim:/SoC_tb/dut/apb_decoder/new_instruction_Tx \
sim:/SoC_tb/dut/apb_decoder/new_instruction_Rx \
sim:/SoC_tb/dut/apb_decoder/lock
add wave -position insertpoint  \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/FIFO_WIDTH_T \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/FIFO_DEPTH_T \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/IDLE \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/RECEIVE \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/WAIT \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/ACTIVE \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/RESET \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/baud_clk \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/rst \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/start_Tx \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/start_Rx \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/parity_bit \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/data_in \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/Rx_ready \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/new_instruction_Tx \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/PREADY_W \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/TxFF \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/data_out \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/Tx_FIFO \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/TxFE \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/active_flag \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/done_transmission \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/serial_counter \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/filling_counter \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/sending_counter \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/bus \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/waiting \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/ns \
sim:/SoC_tb/dut/uart_top/Tx_unit/Tx_fifo/cs
add wave -position insertpoint  \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/FIFO_WIDTH_R \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/FIFO_DEPTH_R \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/IDLE \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/ACTIVE \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/FILLING \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/READY \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/TRANSMITTING \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/WAIT \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/baud_clk \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/rst \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/data_in \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/receive_order \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/new_instruction_Rx \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/RxFE \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/Rx_ready \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/Rx_ready_APB \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/data_out \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/Rx_FIFO \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/RxFF \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/transfer_flag \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/done_receiving \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/R_bus \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/serial_counter \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/filling_counter \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/sending_counter \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/break_counter \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/FE \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/BE \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/OE \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/ns \
sim:/SoC_tb/dut/uart_top/Rx_unit/Rx_fifo/cs
run -all