module cla_8bit(S, G, P, a, b, g, p, c0);
    input [7:0] a,b, g, p;
    input c0;
    output [7:0] S;
    output G, P;

    wire[7:0] c;
    wire c11, c21, c22, c41, c42, c43, c44, c51, c52, c53, c54, c55, c61, c62, c63, c64, c65, c66, c71, c72, c73, c74, c75, c76, c77, g2, g3, g4, g5, g6, g7, g8;

    // c0
    assign c[0] = c0;

    // c1
    and c_11(c11, c[0], p[0]);
    or c_12(c[1], g[0], c11);

    // c2
    and c_21(c21, c[0], p[0], p[1]);
    and c_22(c22, g[0], p[1]);
    or c_2(c[2], c21, c22, g[1]);

    // c3
    and c_31(c31, c[0], p[0], p[1], p[2]);
    and c_32(c32, p[1], g[0], p[2]);
    and c_33(c33, p[2], g[1]);
    or c_3(c[3], c31, c32, c33, g[2]);


    // c4
    and c_41(c41, c[0], p[0], p[1], p[2], p[3]);
    and c_42(c42, p[1], g[0], p[2], p[3]);
    and c_43(c43, p[2], g[1], p[3]);
    and c_44(c44, p[3], g[2]);
    or c_4(c[4], c41, c42, c43,c44, g[3]);

    // c5
    and c_51(c51, c[0], p[0], p[1], p[2], p[3], p[4]);
    and c_52(c52, g[0], p[1], p[2], p[3], p[4]);
    and c_53(c53, g[1], p[2], p[3], p[4]);
    and c_54(c54, g[2], p[3], p[4]);
    and c_55(c55, g[3], p[4]);
    or c_5(c[5], c51, c52, c53,c54, c55, g[4]);

    // c6
    and c_61(c61, c[0], p[0], p[1], p[2], p[3], p[4], p[5]);
    and c_62(c62, g[0], p[1], p[2], p[3], p[4], p[5]);
    and c_63(c63, g[1], p[2], p[3], p[4], p[5]);
    and c_64(c64, g[2], p[3], p[4], p[5]);
    and c_65(c65, g[3], p[4], p[5]);
    and c_66(c66, g[4], p[5]);
    or c_6(c[6], c61, c62, c63,c64, c65, c66, g[5]);

    // c7
    and c_71(c71, c[0], p[0], p[1], p[2], p[3], p[4], p[5], p[6]);
    and c_72(c72, g[0], p[1], p[2], p[3], p[4], p[5], p[6]);
    and c_73(c73, g[1], p[2], p[3], p[4], p[5], p[6]);
    and c_74(c74, g[2], p[3], p[4], p[5], p[6]);
    and c_75(c75, g[3], p[4], p[5], p[6]);
    and c_76(c76, g[4], p[5], p[6]);
    and c_77(c77, g[5], p[6]);
    or c_7(c[7], c71, c72, c73,c74, c75, c76, c77, g[6]);

    // calculate G
    and g_2(g2, g[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);
    and g_3(g3, g[1], p[2], p[3], p[4], p[5], p[6], p[7]);
    and g_4(g4, g[2], p[3], p[4], p[5], p[6], p[7]);
    and g_5(g5, g[3], p[4], p[5], p[6], p[7]);
    and g_6(g6, g[4], p[5], p[6], p[7]);
    and g_7(g7, g[5], p[6], p[7]);
    and g_8(g8, g[6], p[7]);
    or calcG(G, g2, g3, g4, g5, g6, g7, g8, g[7]);


    // calculate P
    and calcP(P, p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]);


    // calculate outputs
    xor s0(S[0], a[0], b[0], c[0]);
    xor s1(S[1], a[1], b[1], c[1]);
    xor s2(S[2], a[2], b[2], c[2]);
    xor s3(S[3], a[3], b[3], c[3]);
    xor s4(S[4], a[4], b[4], c[4]);
    xor s5(S[5], a[5], b[5], c[5]);
    xor s6(S[6], a[6], b[6], c[6]);
    xor s7(S[7], a[7], b[7], c[7]);

endmodule