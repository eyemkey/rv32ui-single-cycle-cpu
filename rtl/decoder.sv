module decoder(
    input logic [31:0] instr, 
    output logic [4:0] rd_addr,  
    output logic [4:0] rs1_addr, 
    output logic [4:0] rs2_addr, 
    output logic [2:0] funct3, 
    output logic mem_re, 
    output logic mem_we, 
    output logic reg_we, 
    output logic [1:0] wb_sel, 
    output logic [1:0] pc_sel,
    output logic alu_src1_sel, 
    output logic alu_src2_sel, 
    output logic [3:0] alu_op
); 

    timeunit 1ns/1ps;

    localparam  R_ARITH = 7'b0110011, 
                I_ARITH = 7'b0010011, 
                I_LOAD  = 7'b0000011, 
                STORE   = 7'b0100011,
                JAL     = 7'b1101111, 
                JALR    = 7'b1100111, 
                LUI     = 7'b0110111, 
                AUIPC   = 7'b0010111, 
                BRANCH  = 7'b1100011, 
                SYSTEM1 = 7'b0001111, 
                SYSTEM2 = 7'b1110011;

    localparam  ALU_ADD = 4'd0, 
                ALU_SUB = 4'd1, 
                ALU_SLL = 4'd2, 
                ALU_SLT = 4'd3, 
                ALU_SLTU= 4'd4, 
                ALU_XOR = 4'd5, 
                ALU_SRL = 4'd6, 
                ALU_SRA = 4'd7, 
                ALU_OR  = 4'd8, 
                ALU_AND = 4'd9, 
                ALU_NOP = 4'd15;

    logic [6:0] opcode; 
    logic [6:0] funct7;

    assign opcode = instr[6:0]; 
    assign funct7 = instr[31:25];

    logic halted;
    logic invalid_instr;

    always_comb begin
        rd_addr = instr[11:7]; 
        rs1_addr = instr[19:15]; 
        rs2_addr = instr[24:20]; 
        funct3  = instr[14:12]; 
        mem_re = 1'b0; 
        mem_we = 1'b0; 
        reg_we = 1'b0; 
        wb_sel = 2'b00; 
        pc_sel = 2'b00;
        alu_src1_sel = 1'b0; 
        alu_src2_sel = 1'b0; 
        alu_op = ALU_NOP;
        invalid_instr = 1'b0; 
        halted = 1'b0;

        unique case(opcode)
            R_ARITH: begin
                reg_we = 1'b1; 
                wb_sel = 2'b00;
                alu_src1_sel = 1'b0; 
                alu_src2_sel = 1'b0; 
                if(funct7 ==   7'b000_0000) begin
                    unique case(funct3)
                        3'b000: alu_op = ALU_ADD; 
                        3'b001: alu_op = ALU_SLL;  
                        3'b010: alu_op = ALU_SLT; 
                        3'b011: alu_op = ALU_SLTU;  
                        3'b100: alu_op = ALU_XOR; 
                        3'b101: alu_op = ALU_SRL; 
                        3'b110: alu_op = ALU_OR; 
                        3'b111: alu_op = ALU_AND;  
                        default: invalid_instr = 1'b1; 
                    endcase
                end
                else if(funct7 ==  7'b010_0000) begin
                    unique case(funct3)
                        3'b000: alu_op = ALU_SUB; 
                        3'b101: alu_op = ALU_SRA; 
                        default:  invalid_instr = 1'b1; 
                    endcase
                end
                else invalid_instr =  1'b1;  
            end

            I_ARITH: begin
                reg_we = 1'b1; 
                wb_sel = 2'b00; 
                alu_src1_sel = 1'b0; 
                alu_src2_sel =  1'b1; 
                unique case(funct3)
                    3'b000: alu_op = ALU_ADD; 
                    3'b001: begin
                        if(funct7 == 7'b000_0000) alu_op = ALU_SLL;
                        else invalid_instr = 1'b1; 
                    end
                    3'b010: alu_op = ALU_SLT; 
                    3'b011: alu_op = ALU_SLTU; 
                    3'b100: alu_op = ALU_XOR; 
                    3'b101: begin
                        if(funct7 == 7'b000_0000) alu_op = ALU_SRL; 
                        else if(funct7 == 7'b010_0000) alu_op = ALU_SRA; 
                        else invalid_instr = 1'b1; 
                    end
                    3'b110: alu_op = ALU_OR; 
                    3'b111: alu_op = ALU_AND;
                    default: invalid_instr = 1'b1; 
                endcase
            end

            I_LOAD: begin
                unique case(funct3)  
                    3'b000, 3'b001, 3'b010, 3'b100,  3'b101: invalid_instr = 1'b0; 
                    default: invalid_instr = 1'b1; 
                endcase
                mem_re = 1'b1; 
                reg_we = 1'b1; 
                wb_sel = 2'b01; 
                alu_src1_sel = 1'b0; 
                alu_src2_sel = 1'b1; 
                alu_op = ALU_ADD;
            end

            STORE: begin
                unique case(funct3)  
                    3'b000, 3'b001, 3'b010: invalid_instr = 1'b0; 
                    default: invalid_instr = 1'b1; 
                endcase
                mem_we = 1'b1;
                alu_src1_sel = 1'b0; 
                alu_src2_sel = 1'b1;  
                alu_op = ALU_ADD;
            end

            JAL: begin
                reg_we = 1'b1; 
                wb_sel = 2'b10; 
                pc_sel = 2'b01; 
                alu_src1_sel = 1'b0; 
                alu_src2_sel = 1'b1; 
                alu_op = ALU_ADD;
            end

            JALR: begin
                reg_we = 1'b1; 
                wb_sel = 2'b10; 
                pc_sel = 2'b10; 
                alu_src1_sel = 1'b0; 
                alu_src2_sel = 1'b1; 
                alu_op = ALU_ADD; 
            end

            LUI: begin
                reg_we = 1'b1;  
                wb_sel = 2'b11; 
            end

            AUIPC: begin
                reg_we = 1'b1; 
                wb_sel = 2'b00; 
                alu_src1_sel = 1'b1; 
                alu_src2_sel = 1'b1;
                alu_op = ALU_ADD; 
            end

            SYSTEM1: begin
                invalid_instr = 1'b0; 
            end

            SYSTEM2: begin
                if(funct7 == 7'b000_0000 && (rs2_addr == 5'b0_0001 || rs2_addr == 5'b0_0000))
                    halted = 1'b1; 
            end
            default: invalid_instr = 1'b1; 
        endcase
        if(invalid_instr) $fatal(1, "Invalid Instruction: instr=%h", instr); 
        if(halted) begin
            $display("ECALL/EBREAK: Program Halted"); 
            $finish; 
        end
    end
endmodule
