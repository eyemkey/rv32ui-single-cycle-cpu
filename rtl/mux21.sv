module mux21(
    input logic sel,
    input logic [31:0] i1, 
    input logic [31:0] i2, 
    output logic [31:0] o
);
    timeunit 1ns/1ps;

    always_comb begin
        if(sel == 1)
            o = i2; 
        else o = i1; 
    end

endmodule
