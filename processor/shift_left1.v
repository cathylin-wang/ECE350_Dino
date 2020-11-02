module shift_left1(out, in);
    input [31:0] in;
    output [31:0] out;
    
    assign out[0] = 0;
    assign out[31:1] = in[30:0];


endmodule


// and would this work?
/*
module shift_left8(in, out);
    input [31:0] in;

    output [31:0] out;
    
    // can i do this?
    out [31:8] = in [23:0];
    out[7:0] = 0;

endmodule
*/