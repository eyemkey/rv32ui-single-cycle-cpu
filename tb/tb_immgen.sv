module tb_immgen; 

    timeunit 1ns/1ps; 

    logic [31:0] instr; 
    logic [31:0] imm; 

    immgen dut(
        .instr(instr), 
        .imm(imm)
    );

    task automatic verify(input logic [31:0] new_instr, input logic [31:0] exp_imm); 
        begin
            instr = new_instr; 
            #1; 
            if(imm !== exp_imm) begin
                $fatal(1, "tb_immgen: ERROR! imm mismatch: time=%0t | imm=%h | exp_imm=%h", $time, imm, exp_imm);
            end
        end
    endtask 

    initial begin

        verify(32'h0050_0013, 32'h0000_0005);
        verify(32'hFFF0_0013, 32'hFFFF_FFFF); 
        verify(32'h0030_1013, 32'h0000_0003); 
        verify(32'h01F0_5013, 32'h0000_001F); 
        verify(32'h0100_2003, 32'h0000_0010); 
        verify(32'h8000_2003, 32'hFFFF_F800);
        verify(32'h0000_2A23, 32'h0000_0014); 
        verify(32'hFE00_2823, 32'hFFFF_FFF0);
        verify(32'h0000_0863, 32'h0000_0010); 
        verify(32'hFE00_08E3, 32'hFFFF_FFF0); 
        verify(32'h1234_5037, 32'h1234_5000); 
        verify(32'hABCD_E017, 32'hABCD_E000); 
        verify(32'h0010_006F, 32'h0000_0800); 
        verify(32'h801F_F06F, 32'hFFFF_F800);

        $display("tb_immgen: [PASS] All tests passed!");
        $finish;
    end

endmodule 
