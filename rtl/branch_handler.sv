module branch_handler(
    input logic [31:0] rs1_data, 
    input logic [31:0] rs2_data, 
    input logic [2:0] funct3, 
    input logic [31:0] alu_out, 
    input logic [31:0] pc4, 
    output logic [31:0] branch_out
); 
    timeunit 1ns/1ps;

    logic condition; 
    always_comb begin
        condition = 1'b0; 
        branch_out = 32'h0000_0000; 
        unique case(funct3)
            3'b000: condition = (rs1_data == rs2_data); 
            3'b001: condition = (rs1_data != rs2_data); 
            3'b100: condition = ($signed(rs1_data) < $signed(rs2_data)); 
            3'b101: condition = ($signed(rs1_data) >= $signed(rs2_data));  
            3'b110: condition = ($unsigned(rs1_data) < $unsigned(rs2_data));
            3'b111: condition = ($unsigned(rs1_data) >= $unsigned(rs2_data));
            default: condition = 1'b0;
        endcase 

        branch_out = (condition) ? alu_out : pc4; 
    end

endmodule
