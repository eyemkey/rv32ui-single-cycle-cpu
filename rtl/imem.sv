module imem #(
    parameter logic[31:0] BASE_PC = 32'h0000_0000, 
    parameter int unsigned DEPTH_WORDS = 512
) (
    input logic [31:0] pc, 
    output logic [31:0] instr
);
    timeunit 1ns/1ps;

    logic [31:0] instructions [0:DEPTH_WORDS - 1];
    
    logic [31:0] addr; 

    always_comb begin
        addr = pc - BASE_PC;
        if((addr >> 2) >= DEPTH_WORDS)
            instr = 32'h0000_0013;
        else
            instr = instructions[addr >> 2];
    end

endmodule