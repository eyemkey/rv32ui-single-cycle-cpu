module tb_imem; 

    timeunit 1ns/1ps;

    localparam logic [31:0] BASE_PC = 32'h0000_0000; 
    localparam int unsigned DEPTH_WORDS =  8; 

    logic [31:0] pc;  
    logic [31:0] instr; 

    imem #(.BASE_PC(BASE_PC), .DEPTH_WORDS(DEPTH_WORDS)) dut (
        .pc(pc), 
        .instr(instr)
    ); 

    task automatic verify(input logic [31:0] pc_in, input logic [31:0] exp_instr); 
        begin
            pc = pc_in; 
            #1; 
            if(instr !== exp_instr) begin
                $fatal(1, "IMEM mismatch: time=%0t | pc=%h | instr=%h | exp=%h", 
                        $time, pc, instr, exp_instr);
            end
        end
    endtask

    initial begin
        pc = BASE_PC; 

        dut.instructions[0] = 32'h1111_1111;
        dut.instructions[1] = 32'h2222_2222;
        dut.instructions[2] = 32'h3333_3333;
        dut.instructions[3] = 32'h4444_4444;

        verify(BASE_PC + 32'd0, 32'h1111_1111); 
        verify(BASE_PC + 32'd4, 32'h2222_2222); 
        verify(BASE_PC + 32'd8, 32'h3333_3333);
        verify(BASE_PC + 32'd12, 32'h4444_4444); 

        verify(BASE_PC + (DEPTH_WORDS * 4), 32'h0000_0013); 
        verify(BASE_PC + 32'd4096, 32'h0000_0013); 

        $display("[PASS] tb_imem: All tests pased!");
        $finish;
    end

endmodule
