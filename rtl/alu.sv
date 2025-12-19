module alu(
    input  logic [31:0] alu_src1,
    input  logic [31:0] alu_src2,
    input  logic [3:0]  alu_op,
    output logic [31:0] alu_out
);
    timeunit 1ns/1ps;

    localparam logic [3:0]
        ALU_ADD  = 4'd0,
        ALU_SUB  = 4'd1,
        ALU_SLL  = 4'd2,
        ALU_SLT  = 4'd3,
        ALU_SLTU = 4'd4,
        ALU_XOR  = 4'd5,
        ALU_SRL  = 4'd6,
        ALU_SRA  = 4'd7,
        ALU_OR   = 4'd8,
        ALU_AND  = 4'd9,
        ALU_NOP  = 4'd15;

    logic [4:0] shamt;
    assign shamt = alu_src2[4:0];

    always_comb begin
        alu_out = 32'h0000_0000; // safe default

        unique case (alu_op)
            ALU_ADD:  alu_out = alu_src1 + alu_src2;
            ALU_SUB:  alu_out = alu_src1 - alu_src2;
            ALU_SLL:  alu_out = alu_src1 << shamt;
            ALU_SLT:  alu_out = ($signed(alu_src1) < $signed(alu_src2)) ? 32'd1 : 32'd0;
            ALU_SLTU: alu_out = ($unsigned(alu_src1) < $unsigned(alu_src2)) ? 32'd1 : 32'd0;
            ALU_XOR:  alu_out = alu_src1 ^ alu_src2;
            ALU_SRL:  alu_out = alu_src1 >> shamt;
            ALU_SRA:  alu_out = $signed(alu_src1) >>> shamt;
            ALU_OR:   alu_out = alu_src1 | alu_src2;
            ALU_AND:  alu_out = alu_src1 & alu_src2;
            ALU_NOP:  alu_out = 32'd0;
            default:  $fatal(1, "Invalid alu operation");
        endcase
    end
endmodule
