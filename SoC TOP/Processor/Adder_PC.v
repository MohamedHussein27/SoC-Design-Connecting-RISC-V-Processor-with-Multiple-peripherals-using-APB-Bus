module Adder_PC(
    // nodified for SoC
    input stop,
    input [31:0] PC , ImmExt ,
    output [31:0] PCTarget 
);
assign PCTarget = (stop) ? PC : PC + ImmExt ;
/*reg pause_imm;
always @(*) begin
    if(stop && pause_imm !== 1) begin
        PCTarget = PC - ImmExt;
        pause_imm = 1;
    end
    else if (stop && pause_imm === 1)
        PCTarget = PC;
    else begin
        PCTarget = PC + ImmExt;
        pause_imm = 0;
    end
end*/
endmodule