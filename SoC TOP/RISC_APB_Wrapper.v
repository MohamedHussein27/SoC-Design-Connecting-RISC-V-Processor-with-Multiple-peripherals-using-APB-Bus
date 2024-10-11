// this module is to connect between our processor (RISC-V) and the APB Master communication Protocol
module RISC_APB_Wrapper (
    input [31:0] instruction,  // instructiontion from inst. memory in RISC-V
    input [31:0] RD1, RD2, // content of registers rs1 , rs2 in RISC-V
    input clk, rst,
    input READY, SLVERR, // READY signal when high then we are back to the normal RISC-V cycle
    output stop, // stop signal to stop the RISC_V PC from incerementing untill the data is sent or received using APB
    output reg transfer, // to start using the APB master
    output reg SWRITE ,
    output reg [31:0] SADDR , SWDATA,  
    output reg [3:0] SSTRB,
    // modified to handle data memory in case of using APB
    output cancel_data_memory  // to cancel using data memory in case of lw or sw in prephral
);
    localparam  IDLE = 0, 
                WAIT_W = 1, // state for using APB prepherals to write into instead of data memory
                WAIT_R = 2, // state for using APB prepherals to read from instead of data memory
                //DONE = 3; // state to announce that reading or writing in any prephral we chose has done
                READY_WAIT = 3; // state to wait for the READY signal to be zero to start again
    reg flag; // flag to down cancel_data_memory signal when high 
    reg [1:0] cs , ns;
    // state memory
    always @(posedge clk) begin
        if (~rst)
            cs <= IDLE;
        else 
            cs <= ns;
    end

    // next state logic
    always @(*) begin
        case(cs)
            IDLE: begin
                if((instruction[6:0] == 7'b0100011) && (({instruction[31:25],instruction[11:7]} + RD1) >= 1000) && (instruction[31:28] != 4'b1111)) // sw instructiontion with address greater than 1000, then go to APB 
                    ns = WAIT_W;
                else if((instruction[6:0] == 7'b0000011) && ((instruction[31:20] + RD1) >= 1000)&& (instruction[31:28] != 4'b1111)) // lw instructiontion with address greater than 1000, then go to APB 
                    ns = WAIT_R;
                else
                    ns = IDLE;
            end
            WAIT_W: begin
                if(READY)
                    ns = READY_WAIT;
                else
                    ns = WAIT_W;
            end
            WAIT_R: begin
                if (READY)
                    ns = READY_WAIT;
                else
                    ns = WAIT_R;
            end    
            //DONE: ns = READY_WAIT;
            READY_WAIT: begin
                if (READY)
                    ns = READY_WAIT;
                else
                    ns = IDLE;
            end
        endcase
    end
        
    // output logic
    always @(*) begin
        if (cs == IDLE) begin
            transfer = 0;
            SWRITE = 0;
            SADDR = 0;
            flag = 0;
            //stop = 0;
            SWDATA = 0;
            //cancel_data_memory = 0;
            SSTRB = 4'b1111; // default 
        end
        else if (cs == WAIT_W) begin
            //stop = 1; // stop RISC_V untill we get the READY signal
            transfer = 1;
            SWRITE = 1;  // writing
            SADDR = {instruction[31:25],instruction[11:7]} + RD1;
            SWDATA = RD2;
            flag = 1;
            //cancel_data_memory = 1;
        end
        else if (cs == WAIT_R) begin
            //stop = 1; // stop RISC_V untill we get the READY signal
            transfer = 1;
            SWRITE = 0; // reading
            SADDR = instruction[31:20] + RD1;
            flag = 1;
            //cancel_data_memory = 1;
        end
        else if (cs == READY_WAIT) begin
            //stop = 0;
            //cancel_data_memory = 1;
            //flag = 0;
            transfer = 0;
            SWRITE = 0;
            SADDR = 0;
        end
    end  
    //assign stop = ((ns == WAIT_W) || (ns == WAIT_R)) ? 1 : 0; // used ns instead of cs as i want it at the same clock cycle
    assign stop  = (ns != IDLE) ? 1 : 0;
    //assign cancel_data_memory = ((ns == WAIT_W) || (ns == WAIT_R)) ? 1 : 
                                                      //(flag) ? 1 : 0;
    assign cancel_data_memory = (ns != IDLE) ? 1 :
                                    (flag) ? 1 : 0;
endmodule