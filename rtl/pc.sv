module pc #(
    parameter logic [31:0] BASE_PC = 32'h0000_0000
) (
    input logic         clk, 
    input logic         rst_n, 
    input logic [31:0]  next_pc,
    output logic [31:0] pc
);
  
    timeunit 1ns/1ps;

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n)
            pc <= BASE_PC;
        else pc <= next_pc;
    end

endmodule