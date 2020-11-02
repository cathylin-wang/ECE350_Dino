module my_tri(out, in, oe);
    input[31:0] in;
    output[31:0] out;

    input oe;

    assign out = oe ? in : 32'bz;

endmodule