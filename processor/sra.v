module sra(out, in, shiftby);
    input [31:0] in;
    input [4:0] shiftby; // need 5 bits to select from 0-31
    output [31:0] out;
    
    wire [31:0] s16, s8, s4, s2, s1, in16, in8, in4, in2, in1;

    sra16 first(s16, in);

    // 8 
    mux_2 pre8(in8, shiftby[4], in, s16);
    sra8 shift8(s8, in8);

    //4
    mux_2 pre4(in4, shiftby[3], in8, s8);
    sra4 shift4(s4, in4);

    //2
    mux_2 pre2(in2, shiftby[2], in4, s4);
    sra2 shift2(s2, in2);

    //1
    mux_2 pre1(in1, shiftby[1], in2, s2);
    sra1 shift1(s1, in1);

    mux_2 final(out, shiftby[0], in1, s1);

endmodule