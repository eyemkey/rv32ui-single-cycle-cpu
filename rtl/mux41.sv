module mux41(
    input logic [1:0] sel, 
    input logic [31:0] i1, 
    input logic [31:0] i2, 
    input logic [31:0] i3, 
    input logic [31:0] i4, 
    output logic [31:0] o
);

    logic [31:0] mux1_out;
    logic [31:0] mux2_out; 
    mux21 mux1(
        .sel(sel[0]), 
        .i1(i1), 
        .i2(i2),
        .o(mux1_out)
    );

    mux21 mux2(
        .sel(sel[0]),
        .i1(i3),
        .i2(i4),
        .o(mux2_out)
    );

    mux21 mux3(
        .sel(sel[1]),
        .i1(mux1_out), 
        .i2(mux2_out), 
        .o(o)
    );

endmodule
