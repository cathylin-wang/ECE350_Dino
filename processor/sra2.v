module sra2(out, in);
    input [31:0] in;
    output [31:0] out;
    
    assign out[31] = in[31];
    assign out[30] = in[31];
    assign out[29:0] = in[31:2];

endmodule


