module immgen(
    input logic [31:0] instr,
    output logic [31:0] imm
);

    timeunit 1ns/1ps; 

    localparam  I_ARITH = 7'b0010011, 
                I_LOAD  = 7'b0000011, 
                STORE   = 7'b0100011,
                JAL     = 7'b1101111, 
                JALR    = 7'b1100111, 
                LUI     = 7'b0110111, 
                AUIPC   = 7'b0010111, 
                BRANCH  = 7'b1100011;
    logic [6:0] opcode;
    logic [2:0] funct3; 
    always_comb begin
        opcode = instr[6:0];
        funct3 = instr[14:12]; 
        unique case(opcode)
            I_ARITH: begin
                unique case(funct3)
                    3'b001, 3'b101: imm = {27'b0, instr[24:20]};
                    default: imm = {{20{instr[31]}}, instr[31:20]};
                endcase
            end
            I_LOAD: imm = {{20{instr[31]}}, instr[31:20]};
            STORE: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            JAL: imm = {{12{instr[31]}} , instr[19:12], instr[20], instr[30:21], 1'b0};
            JALR: imm = {{20{instr[31]}}, instr[31:20]};
            LUI, AUIPC: imm = {instr[31:12], 12'b0};
            BRANCH: imm = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            default: imm = 32'h0000_0000;
        endcase
        
    end

endmodule 
