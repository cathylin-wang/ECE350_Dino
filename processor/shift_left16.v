
module shift_left16(out, in);
    input [31:0] in;
    output [31:0] out;
    
    assign out [31:16] = in [15:0];
    assign out[15:0] = 0;

endmodule