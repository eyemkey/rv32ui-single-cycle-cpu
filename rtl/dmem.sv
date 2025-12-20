module dmem
#(parameter DEPTH=32)
(
    input logic clk, 
    input logic rst_n, 
    input logic [31:0] rs2_data, 
    input logic [31:0] addr, 
    input logic [2:0] funct3, 
    input logic mem_re, 
    input logic mem_we, 
    output logic [31:0] mem_data
); 

    timeunit 1ns/1ps;

    logic [7:0] memory [0:DEPTH-1];

    always_comb begin
        mem_data = 32'h0000_0000;
        if(mem_re && !mem_we) begin
            unique case(funct3)
                3'b000: begin
                    if($unsigned(addr) < DEPTH)
                        mem_data = {{24{memory[addr][7]}}, memory[addr]};
                end
                3'b001: begin
                    if($unsigned(addr) + 1 < DEPTH && addr[0] == 1'b0) 
                        mem_data = {{16{memory[addr+1][7]}}, memory[addr+1], memory[addr]};
                end
                3'b010: begin
                    if($unsigned(addr) + 3 < DEPTH && addr[1:0] == 2'b00)
                        mem_data = {memory[addr+3], memory[addr+2], memory[addr+1], memory[addr]}; 
                end
                3'b100: begin
                    if($unsigned(addr) < DEPTH)
                        mem_data = {24'b0, memory[addr]};
                end
                3'b101: begin
                    if($unsigned(addr) + 1< DEPTH && addr[0] == 1'b0)
                        mem_data = {16'b0, memory[addr+1], memory[addr]};
                end
                default: mem_data = 32'h0000_0000;
            endcase
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            integer i; 
            for(i = 0; i < DEPTH; i = i + 1) begin
                memory[i] <= 8'b0; 
            end
        end

        else if(mem_we && !mem_re) begin
            unique case(funct3)
                3'b000: begin
                    if($unsigned(addr) < DEPTH)
                        memory[addr] <= rs2_data[7:0]; 
                end
                3'b001: begin
                    if($unsigned(addr) + 1 < DEPTH && addr[0] == 1'b0) begin
                        memory[addr] <= rs2_data[7:0]; 
                        memory[addr+1] <= rs2_data[15:8];
                    end 
                end
                3'b010: begin
                    if($unsigned(addr) + 3 < DEPTH && addr[1:0] == 2'b00) begin
                        memory[addr] <= rs2_data[7:0]; 
                        memory[addr+1] <= rs2_data[15:8]; 
                        memory[addr+2] <= rs2_data[23:16]; 
                        memory[addr+3] <= rs2_data[31:24];
                    end
                end
                default: $fatal(1, "Invalid store operation"); 
            endcase
        end


    end


endmodule
