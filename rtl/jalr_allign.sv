module jalr_allign(
    input logic [31:0] alu_out, 
    output logic [31:0] jalr_pc
); 
    timeunit 1ns/1ps;
    assign jalr_pc = alu_out & 32'hFFFF_FFFE; 
endmodule
