module m_latch(o, bd, ir_out, rdout, oin, bdin, ir_in, rdin, clock, clear);
    input clock, clear;
    input [4:0] rdin;
    input [31:0] ir_in, oin, bdin;
    output [4:0] rdout;
    output [31:0] ir_out, o, bd;

// module register(out, in, clk, input_enable, clr);
    register IR(ir_out, ir_in, clock, 1'b1, clear);
    register O(o, oin, clock, 1'b1, clear);
    register BD(bd, bdin, clock, 1'b1, clear);
    register5 rd(rdout,rdin, clock, 1'b1, clear);

endmodule