module regfile(
    input logic clk, 
    input logic rst_n,
    input logic [31:0] rd_wdata,
    input logic [4:0] rd_addr, 
    input logic [4:0] rs1_addr, 
    input logic [4:0] rs2_addr, 
    input logic reg_we, 
    output logic [31:0] rs1_data, 
    output logic [31:0] rs2_data
); 
    timeunit 1ns/1ps;

    logic [31:0] registers [0:31]; 

    always_comb begin
        rs1_data = (rs1_addr == 5'd0) ? 32'h0000_0000 : registers[rs1_addr]; 
        rs2_data = (rs2_addr == 5'd0) ? 32'h0000_0000 : registers[rs2_addr]; 

        if (reg_we && (rd_addr != 5'd0) && (rs1_addr == rd_addr))
            rs1_data = rd_wdata;

        if (reg_we && (rd_addr != 5'd0) && (rs2_addr == rd_addr))
            rs2_data = rd_wdata;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            integer i;
            for(i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'h0000_0000; 
            end
        end
        else if(reg_we && rd_addr != 5'd0)
            registers[rd_addr] <= rd_wdata; 
        registers[0] <= 32'h0000_0000; 
    end

endmodule

