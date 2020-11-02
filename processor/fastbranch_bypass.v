module fastbranch_bypass(outa, outb, rega, regb, data_readRegA, data_readRegB, dx_ir, xm_ir, dx_rd, xm_rd, mw_rd, dx_o, xm_o, mw_o, q_dmem0, ctrl_writeEnable);
    input[31:0] dx_ir, xm_ir, data_readRegA, data_readRegB, dx_o, xm_o, mw_o, q_dmem0;
    input [4:0] dx_rd, xm_rd, mw_rd, rega, regb;
    input ctrl_writeEnable;
    output [31:0] outa, outb;

    //already know ra and rb, calculated in same cycle so i dont have to repeat
    // TO DO: check execute rd, execute write enable, execute rd
    



    wire [4:0] dx_opcode, xm_opcode;

    assign dx_opcode = dx_ir[31:27];
    assign xm_opcode = xm_ir[31:27];


    wire xm_ctrl_writeEnable, dx_ctrl_writeEnable;
    assign xm_ctrl_writeEnable = (xm_opcode == 5'b01000) | (xm_opcode == 5'b00000) | (xm_opcode == 5'b00011)| | (xm_opcode == 5'b10101) | (xm_opcode == 5'b00101);
    assign dx_ctrl_writeEnable = (dx_opcode == 5'b01000) | (dx_opcode == 5'b00000) | (dx_opcode == 5'b00011)| | (dx_opcode == 5'b10101) | (dx_opcode == 5'b00101);
    // writeback_islw | writeback_isALUOp | writeback_isJAL | writeback_isSetx | is addi;
    //to do: and write enable for sel from xm

    wire[31:0] memory_bypass; //memory bypass: read d from memory if load word, otherwise read o
    wire[4:0] xm_lw;
    assign xm_lw = xm_opcode == 5'b01000;
    assign memory_bypass = xm_lw ? q_dmem0 : xm_o;

    wire[31:0] aw, am, ax;
    // if (rs = mwrd && mwrd != 0) bypass from writeback
    assign  aw = (rega == mw_rd & mw_rd != 5'd0 & ctrl_writeEnable) ? mw_o : data_readRegA;
    // if (rs = xmrd && xmrd != 0) bypass from memory
    assign am = (rega == xm_rd & xm_rd != 5'd0 & xm_ctrl_writeEnable) ? memory_bypass : aw;
    // if (rs = dxrd && dxrd != 0) bypass from execute
    assign outa = (rega == dx_rd & dx_rd != 5'd0 & dx_ctrl_writeEnable) ? dx_o : am;


    wire[31:0] bw, bm, bx;
    // if (rs = mwrd && mwrd != 0) bypass from writeback
    assign  bw = (regb == mw_rd & mw_rd != 5'd0 & ctrl_writeEnable) ? mw_o : data_readRegB;
    // if (rs = xmrd && xmrd != 0) bypass from memory
    assign bm = (regb == xm_rd & xm_rd != 5'd0 & xm_ctrl_writeEnable) ? memory_bypass : bw;
    // if (rs = dxrd && dxrd != 0) bypass from execute
    assign outb = (regb == dx_rd & dx_rd != 5'd0 & dx_ctrl_writeEnable) ? dx_o : bm;

endmodule