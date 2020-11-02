// module divcounter(data_resultRDY, clk, ctrl_MULT, ctrl_DIV);

//     input clk, ctrl_MULT, ctrl_DIV;

//     output data_resultRDY;
//     wire[31:0] intermed;


//     dffe_ref dff0(intermed[0], ctrl_DIV, clk, 1'b1, 1'b0);
//     dffe_ref dff1(intermed[1], intermed[0], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff2(intermed[2], intermed[1], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff3(intermed[3], intermed[2], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff4(intermed[4], intermed[3], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff5(intermed[5], intermed[4], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff6(intermed[6], intermed[5], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff7(intermed[7], intermed[6], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff8(intermed[8], intermed[7], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff9(intermed[9], intermed[8], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff10(intermed[10], intermed[9], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff11(intermed[11], intermed[10], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff12(intermed[12], intermed[11], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff13(intermed[13], intermed[12], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff14(intermed[14], intermed[13], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff15(intermed[15], intermed[14], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff16(intermed[16], intermed[15], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff17(intermed[17], intermed[16], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff18(intermed[18], intermed[17], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff19(intermed[19], intermed[18], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff20(intermed[20], intermed[19], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff21(intermed[21], intermed[20], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff22(intermed[22], intermed[21], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff23(intermed[23], intermed[22], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff24(intermed[24], intermed[23], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff25(intermed[25], intermed[24], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff26(intermed[26], intermed[25], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff27(intermed[27], intermed[26], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff28(intermed[28], intermed[27], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff29(intermed[29], intermed[28], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff30(intermed[30], intermed[29], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff31(intermed[31], intermed[30], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     dffe_ref dff32(data_resultRDY, intermed[31], clk, 1'b1, ctrl_MULT | ctrl_DIV);
//     // dffe_ref dff31(data_resultRDY, intermed[30], clk, 1'b1, ctrl_MULT | ctrl_DIV);

// endmodule

module divcounter(data_resultRDY, data_resultRDY_hold, clk, ctrl_MULT, ctrl_DIV);

    input clk, ctrl_MULT, ctrl_DIV;

    output data_resultRDY, data_resultRDY_hold;
    wire[31:0] intermed;


    dffe_ref dff0(intermed[0], ctrl_DIV, clk, 1'b1, 1'b0);
    dffe_ref dff1(intermed[1], intermed[0], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff2(intermed[2], intermed[1], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff3(intermed[3], intermed[2], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff4(intermed[4], intermed[3], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff5(intermed[5], intermed[4], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff6(intermed[6], intermed[5], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff7(intermed[7], intermed[6], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff8(intermed[8], intermed[7], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff9(intermed[9], intermed[8], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff10(intermed[10], intermed[9], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff11(intermed[11], intermed[10], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff12(intermed[12], intermed[11], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff13(intermed[13], intermed[12], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff14(intermed[14], intermed[13], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff15(intermed[15], intermed[14], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff16(intermed[16], intermed[15], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff17(intermed[17], intermed[16], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff18(intermed[18], intermed[17], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff19(intermed[19], intermed[18], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff20(intermed[20], intermed[19], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff21(intermed[21], intermed[20], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff22(intermed[22], intermed[21], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff23(intermed[23], intermed[22], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff24(intermed[24], intermed[23], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff25(intermed[25], intermed[24], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff26(intermed[26], intermed[25], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff27(intermed[27], intermed[26], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff28(intermed[28], intermed[27], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff29(intermed[29], intermed[28], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff30(intermed[30], intermed[29], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff31(intermed[31], intermed[30], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dff32(data_resultRDY, intermed[31], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dffplus(data_resultRDY_hold, data_resultRDY, clk, 1'b1, ctrl_MULT | ctrl_DIV);

endmodule

