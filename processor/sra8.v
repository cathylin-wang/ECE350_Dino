module sra8(out, in);
    input [31:0] in;
    output [31:0] out;
    
    assign out[31] = in[31];
    assign out[30] = in[31];
    assign out[29] = in[31];
    assign out[28] = in[31];
    assign out[27] = in[31];
    assign out[26] = in[31];
    assign out[25] = in[31];
    assign out[24] = in[31];
    assign out[23:0] = in[31:8];

endmodule


