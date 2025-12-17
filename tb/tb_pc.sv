module tb_pc; 

    timeunit 1ns/1ps;

    logic clk = 1'b0; 
    logic rst_n = 1'b1; 
    logic [31:0] next_pc; 
    logic [31:0] pc; 
    localparam logic [31:0] RESET_VALUE = 32'h0000_0000;

    always #5 clk <= ~clk; //100MHz clock

    pc #(.BASE_PC(RESET_VALUE)) dut(
        .clk(clk), 
        .rst_n(rst_n), 
        .next_pc(next_pc), 
        .pc(pc)
    );

    task automatic verify(input logic[31:0] exp_pc);
        begin
            next_pc = exp_pc; 
            @(posedge clk); 
            #1;
            if(pc !== exp_pc)
                $fatal(1, "Wrong PC: time=%0t \t| pc=%h \t| exp=%h", $time, pc, exp_pc);
        end
    endtask

    initial begin
        next_pc = 32'h1234_5678;
        rst_n = 1'b0;
        repeat(2) @(posedge clk);
        next_pc = 32'h0000_0000;
        rst_n = 1'b1; 

        //Checking Reset Value
        @(posedge clk); 
        #1; 
        if(pc !== RESET_VALUE)
            $fatal(1, "Reset failed: time=%0t \t| pc=%h \t| RESET_VALUE=%h", $time, pc, RESET_VALUE); 
        
        verify(32'h0000_0004); 
        verify(32'h0000_0008); 
        verify(32'h0000_000A); 
        verify(32'h1000_0000); 

        $display("[PASS] All tests have been passed!"); 
        $finish;
    end


endmodule
