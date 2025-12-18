module tb_regfile; 

    timeunit 1ns/1ps;

    logic clk = 1'b0; 
    logic rst_n; 

    logic [31:0] rd_wdata, rs1_data, rs2_data; 
    logic [4:0] rd_addr, rs1_addr, rs2_addr; 
    logic reg_we; 

    always #5 clk <= ~clk; 

    regfile dut(
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


    task automatic write_reg(input logic [4:0] addr, input logic [31:0] data);
        begin
            rd_addr = addr; 
            rd_wdata = data; 
            reg_we = 1'b1; 
            @(posedge clk); 
            #1; 
            reg_we = 1'b0; 
        end
    endtask

    task automatic expect_read(
        input logic [4:0] addr1, 
        input logic [4:0] addr2, 
        input logic [31:0] exp_data1, 
        input logic [31:0] exp_data2
    ); 
        begin
            rs1_addr = addr1; 
            rs2_addr = addr2;
            #1; 
            if(rs1_data !== exp_data1)
                $fatal(1, "rs1 mismatch: time=%0t | addr=%0d | got=%h | exp=%h", 
                        $time, addr1, rs1_data, exp_data1);
            if(rs2_data !== exp_data2)
                $fatal(1, "rs2 mismatch: time=%0t | addr=%0d | got=%h | exp=%h", 
                        $time, addr2, rs2_data, exp_data2);
        end
    endtask

    initial begin
        rst_n = 1'b0; 
        reg_we = 1'b0; 
        rd_addr = 5'd0; 
        rd_wdata = 32'h0000_0000; 
        rs1_addr = 5'd0; 
        rs2_addr = 5'd0; 

        repeat(2) @(posedge clk); 
        rst_n = 1'b1; 
        #1; 

        expect_read(5'd0, 5'd1, 32'h0000_0000, 32'h0000_0000); 
        expect_read(5'd2, 5'd3, 32'h0000_0000, 32'h0000_0000); 

        write_reg(5'd5, 32'hAAAA_AAAA); 
        expect_read(5'd5, 5'd0, 32'hAAAA_AAAA, 32'h0000_0000); 

        write_reg(5'd10, 32'hBBBB_BBBB); 
        expect_read(5'd10, 5'd0, 32'hBBBB_BBBB, 32'h0000_0000); 

        write_reg(5'd0, 32'h1111_1111); 
        expect_read(5'd0, 5'd10, 32'h0000_0000, 32'hBBBB_BBBB);


        $display("tb_regfile: [PASS] All tests passed!"); 
        $finish;
    end

endmodule
