module register5(out, in, clk, input_enable, clr);
    input clk, input_enable, clr;
    input[4:0] in;
    output[4:0] out;

    dffe_ref dff0(out[0], in[0], clk, input_enable, clr);
    dffe_ref dff1(out[1], in[1], clk, input_enable, clr);
    dffe_ref dff2(out[2], in[2], clk, input_enable, clr);
    dffe_ref dff3(out[3], in[3], clk, input_enable, clr);
    dffe_ref dff4(out[4], in[4], clk, input_enable, clr);

endmodule