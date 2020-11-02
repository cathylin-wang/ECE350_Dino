module fd_latch(pc_out, ir_out, pc_in, ir_in, clock, clear, enable);
// enable = ~ dostall

    input clock, clear, enable;
    input [31:0] pc_in, ir_in;
    output [31:0] pc_out, ir_out;
// module register(out, in, clk, input_enable, clr);

    register PC(pc_out, pc_in, clock, enable, clear);
    register IR(ir_out, ir_in, clock, enable, clear);

endmodule