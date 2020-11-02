module cla_32bit(S, c32, a, b, c0);

    input [31:0] a,b;
    input c0;
    output [31:0] S;
    output c32;

    wire[31:0] g, p;

    wire c8, c16, c24, G0, P0, G1, P1, G2, P2, G3, P3, c8temp, c161, c162, c241, c242, c243, c321, c322, c323, c324;

    // calculate all the g' --- only use bits 0-7
    and32 calcGs(g,a,b);
    // calculate all the p' --- only use bits 0-7
    or32 calcPs(p,a,b);

    // module cla_8bit(S, G, P, a, b, g, p, c0);
    cla_8bit block1(S[7:0], G0, P0, a[7:0], b[7:0], g[7:0], p[7:0], c0);
    cla_8bit block2(S[15:8], G1, P1, a[15:8], b[15:8], g[15:8], p[15:8], c8);
    cla_8bit block3(S[23:16], G2, P2, a[23:16], b[23:16], g[23:16], p[23:16], c16);
    cla_8bit block4(S[31:24], G3, P3, a[31:24], b[31:24], g[31:24], p[31:24], c24);

    // get c8
    and c8_temp(c8temp, c0, P0);
    or getc8(c8, G0, c8temp);

    // get c16
    and c16_1(c161, c0, P0, P1);
    and c16_2(c162, P1, G0);
    or getc16(c16, c161, c162, G1);

    // get c24
    and c24_1(c241, c0, P0, P1, P2);
    and c24_2(c242, G0, P1, P2);
    and c24_3(c243, G1, P2);
    or getc24(c24, c241, c242, c243, G2);

    // get c32
    and c32_1(c321, c0, P0, P1, P2, P3);
    and c32_2(c322, G0, P1, P2, P3);
    and c32_3(c323, G1, P2, P3);
    and c32_4(c324, G2, P3);
    or getc32(c32, c321, c322, c323, c324, G3);

endmodule