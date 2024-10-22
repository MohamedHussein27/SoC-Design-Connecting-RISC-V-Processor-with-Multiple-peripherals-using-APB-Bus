# System on Chip (SoC) Design with RISC-V and UART

## Overview
A **System on Chip (SoC)** is an integrated circuit that incorporates multiple components of a computer system onto a single chip. SoC designs typically include a processor, memory, input/output peripherals, and communication interfaces, making them highly efficient for embedded applications. 

This project showcases a Verilog implementation of an SoC design where the **RISC-V processor** is connected to multiple peripherals. In this design, the primary peripheral is a **UART module**, enabling serial communication. The project demonstrates how these components are integrated and interact with each other.

---

## SoC Structure
![Architecture](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/SoC%20Archeticture.png)

### Work Idea:
- The **RISC APB Wrapper** takes the instruction from the **RISC-V processor** and checks if it is a load word (lw) or store word (sw) instruction with an offset greater than 1000. If so, it stops the processor by freezing the PC counter and routes the instruction through one of the peripherals (e.g., UART).
- The **RISC APB Wrapper** then translates the RISC-V instructions into specific instructions that can be understood by the standard **APB Master bus**.
- The **APB bus** generates the APB signals according to the input signals from the **RISC APB Wrapper** and sends these signals to the **APB Decoder**.
- The **APB Decoder** selects the appropriate peripheral based on the instruction's address offset:
  - If the offset is greater than 1000 and less than 2000, it chooses **Peripheral 1 (UART)**.
  - If the offset is greater than 2000 and less than 3000, it chooses **Peripheral 2**.
  - If the offset is greater than 3000 and less than 4000, it chooses **Peripheral 3**.
- The **APB Decoder** also converts the APB signals to peripheral-specific signals and converts the peripheral signals (e.g., **Ready** signal) back to APB signals to be sent to the APB Master.

> **Note:** If you want a deeper look into each component separately, check the following:
> - [RISC-V Processor](#) *(https://github.com/MohamedHussein27/UART-With-FIFOs)*
> - [APB Protocol](#) *(https://github.com/MohamedHussein27/AMBA-APB4)*
> - [UART Peripheral](#) *(https://github.com/MohamedHussein27/UART-With-FIFOs)*


---

## Primary Signals

| **Signal**           | **Direction** | **Description**                                                                                               |
|----------------------|---------------|---------------------------------------------------------------------------------------------------------------|
| **clk**              | Input         | System clock driving the entire SoC.                                                                          |
| **rst**              | Input         | Resets the SoC logic and peripherals.                                                                         |
| **data_out**         | Output        | Parallel output data from the UART module, increased by one bit (9 bits).                                      |
| **OE**               | Output        | Output error signal for Overrun Error (OE) from UART module.                                                   |
| **BE**               | Output        | Output error signal for Break Error (BE) from UART module.                                                     |
| **FE**               | Output        | Output error signal for Framing Error (FE) from UART module.                                                   |
| **cancel_data_memory** | Wire        | Signal to cancel using data memory in case of `lw` or `sw` in a peripheral.                                    |
| **stop**             | Wire          | Stops the RISC-V PC from incrementing until data is sent or received using the APB bus.                        |
| **Instr**            | Wire          | 32-bit instruction from RISC-V processor.                                                                     |
| **Reg1_out**         | Wire          | 32-bit output wire from RD1 in the register file.                                                             |
| **Reg2_out**         | Wire          | 32-bit output wire from RD2 in the register file.                                                             |
| **READY**            | Wire          | Signal to indicate readiness (high when back to the normal RISC-V cycle).                                      |
| **SLVERR**           | Wire          | Indicates an error signal in the APB transaction.                                                             |
| **transfer**         | Wire          | Signal to start using the APB master.                                                                         |
| **SWRITE**           | Wire          | Write signal for the APB master to indicate a write transaction.                                               |
| **SADDR**            | Wire          | 32-bit address for the APB transaction.                                                                       |
| **SWDATA**           | Wire          | 32-bit write data for the APB transaction.                                                                    |
| **SSTRB**            | Wire          | 4-bit write strobes for the APB transaction (indicates which bytes are active).                                |
| **PSEL**             | Wire          | Peripheral select signal to choose the target peripheral in the APB transaction.                               |
| **PENABLE**          | Wire          | Enable signal for the APB transaction (indicates the second phase of the APB protocol).                        |
| **PWRITE**           | Wire          | Write signal to indicate whether the current APB transaction is a write.                                       |
| **PADDR**            | Wire          | 32-bit address sent to the peripheral in the APB transaction.                                                 |
| **PWDATA**           | Wire          | 32-bit write data sent to the peripheral in the APB transaction.                                              |
| **PSTRB**            | Wire          | 4-bit write strobes sent to the peripheral in the APB transaction.                                            |
| **PREADY**           | Wire          | Ready signal from the peripheral (high when the peripheral is ready to complete the transaction).              |
| **PSLVERR**          | Wire          | Error signal from the peripheral (indicates if there is a failure in the transaction).                         |
| **PREADY_W**         | Wire          | Ready signal for write transactions from the UART peripheral.                                                  |
| **PREADY_R**         | Wire          | Ready signal for read transactions from the UART peripheral.                                                   |
| **PUARTERR**         | Wire          | Error signal from the UART peripheral.                                                                        |
| **Rx_ready_APB**      | Wire         | Flag to indicate that the Rx FIFO is ready for receiving data from the Tx FIFO in the UART peripheral.         |
| **start_Tx**         | Wire          | Start signal for transmission (active low), controlled by `Rx_ready_APB`.                                      |
| **write_uart**       | Wire          | Write signal for the UART peripheral.                                                                         |
| **read_uart**        | Wire          | Read signal for the UART peripheral.                                                                          |
| **parity_sel**       | Wire          | Parity selection signal for the UART module.                                                                  |
| **baud_selector**    | Wire          | 2-bit signal for selecting the baud rate of the UART peripheral.                                              |
| **data_out_to_uart** | Wire          | 8-bit data output to the UART peripheral for transmission.                                                    |
| **new_instruction_Tx** | Wire       | Flag indicating that the upcoming instruction is new for the Tx FIFO, used to reset the serial counter.        |
| **new_instruction_Rx** | Wire       | Flag indicating that the upcoming instruction is new for the Rx FIFO, used to reset the serial counter.        |

> **Note:** these signals are in [SoC.v](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/SoC%20TOP/SoC.v) file

---

## Verifying Functionality

> **Note 1:** In the waveform visualizations:
> - Only selected signals are taken, including **SoC signals**, **RISC_APB_Wrapper signals**, **APB_Decoder signals**, **Tx_FIFO signals**, **Rx_FIFO signals**, and the **data memory** from **RISC-V_Wrapper**.

> **Note 2:** Signal colors in the waveform:
> - **<span style="color:black">SoC</span>** signals are shown in **black**.
> - **<span style="color:green">RISC APB Wrapper</span>** signals are highlighted in **green**.
> - **<span style="color:purple">Tx FIFO</span>** signals are shown in **purple**.
> - **<span style="color:gold">Rx FIFO</span>** signals are displayed in **gold**.
> - **<span style="color:blue">Data memory</span>** signals are represented in **blue**.


In this section, we verify the functionality of the SoC design by simulating various test scenarios that showcase the interaction between the RISC-V processor, APB peripherals, and UART. The scenarios include testing data transmission, error handling, and performance under different conditions.

### First Scenario

- The first 6 instructions are to verify RISC-V Processor, from the 7th instruction we will start to verify our SoC:
![instruction](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/RISC_Instr.png)

- Now we carrying out the instruction: sw x4, 1200(x9) , so we will store x4 value (0Xf) in Tx FIFO in UART Peripheral, notice that the instruction is freezed due to our stop signal which stops the PC counter while using one of the peripherals:
![1st_1](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing%2F1st_1.png)

- After a certain time due to our baud rate, Tx FIFO now has the value 0xF
![1st_2](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing%2F1st_2.png)

- At this time the Data Memory at address (1204/4 = 301) has nothing written into
![1st_3](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/1st_3.png)


### Second Scenario

- Immediately after that the instruction is changed to be: sw x6, 1010(x9), instruction to store the value (0x9) in Tx FIFO, this shows our smooth implementation as the instructions are carried out one after another without a delay
![2nd_1](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/2nd_1.png)

- At the next baud clock positive edge the Tx FIFO now has the two values 
![2nd_2](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/2nd_2.png)

- At this time the address (1014/4 = 253) in Data Memory is empty 
![2nd_3](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/3rd_1.png)

### Third Scenario

- Now the instruction is changing to be: lw x1, 1200(x9), we will first wait the data to be serialized from Tx FIFO to Rx FIFO, then it will be out from data_out signal
![3rd_1](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/3rd_1.png)

- After a long time of serializing data, now the Rx FIFO has the value 0xF
![3rd_2](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/3rd_2.png)

- data is now out from the SoC
![3rd_3](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/3rd_3.png)


### Fourth Scenario

- instruction is changining again to carry out the last instruction in our scenario (lw x7, 1010(x9)) 
![4th_1](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/4th_1.png)

- Rx FIFO has the new value and it’s shown on data_out signal from the SoC
![4th_2](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/4th_2.png)


### Full Wave:
![full_1](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/Full_1.png)
![full_2](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/full_2.png)

---

## Explanation & Speed
All design files have detailed comments within them, so if anyone gets confused about a specific part, they can refer to the design file for clarity.

Additionally, to streamline the testing process, I created a **do file** for the **Tx FIFO** and another for the **Rx FIFO**, enabling faster execution and simulation.

---

## Vivado
- Elaboration:
![Elaboration](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/Elaboration.png)

- Synthesis:
![Synthesis](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/Synthesis.png)

- Implementation:

![Implementation](https://github.com/MohamedHussein27/SoC-Design-Connecting-RISC-V-Processor-with-Multiple-peripherals-using-APB-Bus/blob/main/Structure%20and%20Testing/Implementation.png)

---

### New Releases:
We are excited to announce that new peripherals will be added to this System on Chip (SoC) design, expanding its functionality even further. In future updates:
- Additional peripherals will be connected to the system, providing more versatility.
- The RISC-V processor will be enhanced and **pipelined**, improving performance and efficiency.

Stay tuned for updates and improvements in the next release!

---

## Contact Me!
- [Email](mailto:Mohamed_Hussein2100924@outlook.com)
- [WhatsApp](https://wa.me/+2001097685797)
- [LinkedIn](https://www.linkedin.com/in/mohamed-hussein-274337231)
