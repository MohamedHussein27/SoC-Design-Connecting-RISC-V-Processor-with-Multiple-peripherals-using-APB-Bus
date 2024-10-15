module Adder4(
    // nodified for SoC
    input stop,
    input [31:0] PC ,
    output [31:0] PCPlus4
);
assign PCPlus4 = (stop) ? PC : PC + 4 ; // stop incerementing the PC if stop signal raises 
/*reg pause; // internal flag to decide if it's the first time so decrement the PC by 4 anf then stop on it until the stop signal is deasserted
always @(*) begin
    if(stop && pause !== 1) begin
        PCPlus4 = PC - 4;
        pause = 1;
    end
    else if (stop && pause === 1)
        PCPlus4 = PC;
    else begin
        PCPlus4 = PC + 4;
        pause = 0;
    end
end*/

endmodule