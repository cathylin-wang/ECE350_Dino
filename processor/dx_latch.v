module dx_latch(a, b, pc_out, ir_out, data_readRegA, data_readRegB, pc_in, ir_in, clock, clear);

    input clock, clear;
    input [31:0] pc_in, ir_in, data_readRegA, data_readRegB;
    output [31:0] pc_out, ir_out, a, b;

// module register(out, in, clk, input_1'b1able, clr);
    register PC(pc_out, pc_in, clock, 1'b1, clear);
    register IR(ir_out, ir_in, clock, 1'b1, clear);
    register A(a, data_readRegA, clock, 1'b1, clear);
    register B(b, data_readRegB, clock, 1'b1, clear);

endmodule
    // data_readRegA,                  // I: Data from port A of RegFile
    // data_readRegB                   // I: Data from port B of RegFile