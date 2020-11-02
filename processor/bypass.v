module bypass(selALUinA, selALUinB, selDataMem, dx_ir, xm_ir, xm_rd, mw_rd, ctrl_writeEnable);
    input[31:0] dx_ir, xm_ir;
    input [4:0] xm_rd, mw_rd;
    input ctrl_writeEnable;
    output [1:0] selALUinA, selALUinB;
    output selDataMem;
    
    shouldReadRD CHECKRT(readRD, dx_ir);

    wire [4:0] dx_ir_rs, dx_ir_rt, xm_opcode;
    assign dx_ir_rs = dx_ir[21:17];
    assign dx_ir_rt = readRD ? dx_ir[26:22] : dx_ir[16:12]; // rd or rt?
    assign xm_opcode = xm_ir[31:27];


    wire xm_ctrl_writeEnable;
    assign xm_ctrl_writeEnable = (xm_opcode == 5'b01000) | (xm_opcode == 5'b00000) | (xm_opcode == 5'b00011)| | (xm_opcode == 5'b10101) | (xm_opcode == 5'b00101);
        // writeback_islw | writeback_isALUOp | writeback_isJAL | writeback_isSetx | is addi;
    //to do: and write enable for sel from xm


    wire [1:0] selALUinA_1, selALUinB_1;
    // if (rs = mwrd && mwrd != 0) sel = 1
    assign  selALUinA_1 = (dx_ir_rs == mw_rd & mw_rd != 5'd0 & ctrl_writeEnable) ? 2'd1 : 2'd2;
    // if (rs = xmrd && xmrd != 0) = 0
    assign selALUinA = (dx_ir_rs == xm_rd & xm_rd != 5'd0 & xm_ctrl_writeEnable) ? 2'd0 : selALUinA_1;
    // else 2

    assign selALUinB_1 = (dx_ir_rt == mw_rd & mw_rd != 5'd0 & ctrl_writeEnable) ? 2'd1 : 2'd2;
    assign selALUinB = (dx_ir_rt == xm_rd & xm_rd != 5'd0 & xm_ctrl_writeEnable) ? 2'd0 : selALUinB_1;

    assign selDataMem = ~((xm_rd == mw_rd) & ctrl_writeEnable & mw_rd != 5'd0);

endmodule