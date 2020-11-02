// module counter(data_resultRDY, clk, ctrl_MULT, ctrl_DIV);

//     input clk, ctrl_MULT, ctrl_DIV;

//     output data_resultRDY;
//     wire[15:0] intermed;


//     dffe_ref dff0(intermed[0], ctrl_MULT, clk, 1'b1, 1'b0);
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
//     dffe_ref dff16(data_resultRDY, intermed[15], clk, 1'b1, ctrl_MULT | ctrl_DIV);


// endmodule

module counter(data_resultRDY, data_resultRDY_hold, clk, ctrl_MULT, ctrl_DIV);

    input clk, ctrl_MULT, ctrl_DIV;

    output data_resultRDY, data_resultRDY_hold;
    wire[15:0] intermed;


    dffe_ref dff0(intermed[0], ctrl_MULT, clk, 1'b1, 1'b0);
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
    dffe_ref dff16(data_resultRDY, intermed[15], clk, 1'b1, ctrl_MULT | ctrl_DIV);
    dffe_ref dffplus(data_resultRDY_hold, data_resultRDY, clk, 1'b1, ctrl_MULT | ctrl_DIV);


endmodule

