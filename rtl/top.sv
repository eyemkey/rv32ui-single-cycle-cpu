module top(
    input logic clk, 
    input logic rst_n
);
    timeunit 1ns/1ps;
    logic [31:0] next_pc, pc, pc4; 

    logic [31:0] instr; 

    logic [1:0] wb_sel, pc_sel;
    logic [2:0] funct3; 
    logic [3:0] alu_op;
    logic [4:0] rd_addr, rs1_addr, rs2_addr; 
    logic mem_re, mem_we, reg_we, alu_src1_sel, alu_src2_sel; 

    logic [31:0] imm; 

    logic [31:0] rd_wdata; 
    logic [31:0] rs1_data, rs2_data; 

    logic [31:0] mem_data; 

    logic [31:0] alu_src1, alu_src2, alu_out; 

    logic [31:0] jalr_pc; 
    logic [31:0] branch_out; 

    assign pc4 = pc + 4; 

    pc pc_dut(
        .clk(clk), 
        .rst_n(rst_n),
        .next_pc(next_pc), 
        .pc(pc)
    ); 
    
    imem imem(
        .pc(pc), 
        .instr(instr)
    );

    decoder decoder(
        .instr(instr), 
        .rd_addr(rd_addr), 
        .rs1_addr(rs1_addr), 
        .rs2_addr(rs2_addr), 
        .funct3(funct3), 
        .mem_re(mem_re), 
        .mem_we(mem_we), 
        .reg_we(reg_we), 
        .wb_sel(wb_sel), 
        .pc_sel(pc_sel), 
        .alu_src1_sel(alu_src1_sel), 
        .alu_src2_sel(alu_src2_sel),
        .alu_op(alu_op)
    );

    immgen immgen(
        .instr(instr), 
        .imm(imm)
    ); 

    regfile regfile(
        .clk(clk), 
        .rst_n(rst_n),
        .rd_wdata(rd_wdata), 
        .rd_addr(rd_addr), 
        .rs1_addr(rs1_addr), 
        .rs2_addr(rs2_addr), 
        .reg_we(reg_we), 
        .rs1_data(rs1_data), 
        .rs2_data(rs2_data)
    ); 

    dmem dmem(
        .clk(clk), 
        .rst_n(rst_n),
        .rs2_data(rs2_data),
        .addr(alu_out), 
        .funct3(funct3), 
        .mem_re(mem_re), 
        .mem_we(mem_we), 
        .mem_data(mem_data)
    ); 

    alu alu(
        .alu_src1(alu_src1), 
        .alu_src2(alu_src2), 
        .alu_op(alu_op), 
        .alu_out(alu_out)
    ); 

    jalr_allign jalr_allign(
        .alu_out(alu_out),
        .jalr_pc(jalr_pc)
    ); 

    branch_handler branch_handler(
        .rs1_data(rs1_data), 
        .rs2_data(rs2_data), 
        .funct3(funct3), 
        .alu_out(alu_out), 
        .pc4(pc4), 
        .branch_out(branch_out)
    ); 

    mux41 pc_mux(
        .sel(pc_sel), 
        .i1(pc4), 
        .i2(alu_out), 
        .i3(jalr_pc), 
        .i4(branch_out), 
        .o(next_pc)
    ); 

    mux41 wb_mux(
        .sel(wb_sel), 
        .i1(alu_out), 
        .i2(mem_data), 
        .i3(pc4), 
        .i4(imm), 
        .o(rd_wdata)
    ); 

    mux21 alu_src1_mux(
        .sel(alu_src1_sel), 
        .i1(rs1_data), 
        .i2(pc), 
        .o(alu_src1)
    ); 

    mux21 alu_src2_mux(
        .sel(alu_src2_sel), 
        .i1(rs2_data), 
        .i2(imm), 
        .o(alu_src2)
    ); 

endmodule
