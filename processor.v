/**
 * READ THIS DESCRIPTION!
 *
 * This is your processor module that will contain the bulk of your code submission. You are to implement
 * a 5-stage pipelined processor in this module, accounting for hazards and implementing bypasses as
 * necessary.
 *
 * Ultimately, your processor will be tested by a master skeleton, so the
 * testbench can see which controls signal you active when. Therefore, there needs to be a way to
 * "inject" imem, dmem, and regfile interfaces from some external controller module. The skeleton
 * file, Wrapper.v, acts as a small wrapper around your processor for this purpose. Refer to Wrapper.v
 * for more details.
 *
 * As a result, this module will NOT contain the RegFile nor the memory modules. Study the inputs 
 * very carefully - the RegFile-related I/Os are merely signals to be sent to the RegFile instantiated
 * in your Wrapper module. This is the same for your memory elements. 
 *
 *
 */
module processor(
    // Control signals
    clock,                          // I: The master clock
    reset,                          // I: A reset signal

    // Imem
    address_imem,                   // O: The address of the data to get from imem //index into imem thru pc
    q_imem,                         // I: The data from imem

    // Dmem
    address_dmem,                   // O: The address of the data to get or put from/to dmem
    data,                           // O: The data to write to dmem
    wren,                           // O: Write enable for dmem
    q_dmem,                         // I: The data from dmem

    // Regfile
    ctrl_writeEnable,               // O: Write enable for RegFile
    ctrl_writeReg,                  // O: Register to write to in RegFile
    ctrl_readRegA,                  // O: Register to read from port A of RegFile
    ctrl_readRegB,                  // O: Register to read from port B of RegFile
    data_writeReg,                  // O: Data to write to for RegFile
    data_readRegA,                  // I: Data from port A of RegFile
    data_readRegB                   // I: Data from port B of RegFile
	 
	);

	// Control signals
	input clock, reset;
	
	// Imem
    output [31:0] address_imem;
	input [31:0] q_imem;

	// Dmem
	output [31:0] address_dmem, data;
	output wren;
	input [31:0] q_dmem;

	// Regfile
	output ctrl_writeEnable;
	output [4:0] ctrl_writeReg, ctrl_readRegA, ctrl_readRegB;
	output [31:0] data_writeReg;
	input [31:0] data_readRegA, data_readRegB;

    /************************************************ Variables by Stage ***********************************************/
    /****** initialize ********/
    wire[31:0] q_imem0, q_dmem0;
    assign q_imem0 = reset ? 32'd0 : q_imem;
    assign q_dmem0 = reset ? 32'd0 : q_dmem;
    /******** FETCH ********/
    wire[31:0] pc, pc_in, pc_nxt;

    //fast branch bypass
    wire[31:0] fb_by_a, fb_by_b;


    /******** DECODE ********/
    wire[31:0] fd_pc, fd_ir;
    wire fd_issw;
    wire dostall, multdiv_ready;

    wire[31:0] dx_ir_in;

    /******** EXECUTE ********/
    wire [31:0] dx_a, dx_b, dx_pc, dx_ir;

    wire [31:0] aluOut, alu_b_temp, alu_b;
    wire isALU, isNotEqual, isLessThan, overflow, isaddi, issw, ilw, isBLT, isJal;
    wire [4:0] shamft, aluOpsub, aluOp;
    wire [31:0] immediate;

    // to calculate PC + N
    wire[31:0] branchPC;
    wire branchPC32;
    wire dobranch;

    //set up xm
    wire [4:0] latchRD;
    wire[31:0] xm_o_in;

    //bypass
    wire [31:0] ALU_a, ALU_b;
    wire [1:0] selALUinA, selALUinB;
    wire selDataMem;

    /*** MULTDIV ***/
    wire ctrl_MULT, ctrl_DIV, data_exception, data_resultRDY;
    wire[31:0] p_in; // multdiv result

    wire [31:0] p;
    wire [4:0] pw_rd;
    wire pw_stall, pw_done;

    /******** MEMORY ********/
    wire[31:0] xm_im_in;

    wire [31:0] xm_o, xm_b, xm_ir;
    wire [4:0] xm_rd; //xm_b_in

    wire [4:0] xm_aluOp;

    /******** WRITEBACK ********/
    wire [31:0] mw_o, mw_d, mw_ir;
    wire [4:0] mw_opcode;
        wire[4:0] mw_rd;

    wire writeback_islw, writeback_isALUOp, writeback_isJAL, writeback_isSetx;

	/************************************************ YOUR CODE STARTS HERE ***********************************************/

    /******** FETCH ********/
    
    // wire stall;
    register PC(pc, pc_in, ~clock, ~dostall, reset); 
    assign address_imem = pc;

    wire pc_n_32;
    cla_32bit PC_nxt(pc_nxt, pc_n_32, pc, 0, 1'b1); // cla_32bit(S, c32, a, b, c0);

    /******** DECODE ********/
    wire [31:0] fd_ir_in;
    assign fd_ir_in = doFastBranch | dobranch? 0 : q_imem0;
    fd_latch FD(fd_pc, fd_ir, pc_nxt, fd_ir_in, ~clock, reset, ~dostall); // fd_latch(pc_out, ir_out, pc_in, ir_in, clock, reset);

    // replace fd_ir with dx_ir_in bc we want it to be 0 for noop

    // opcode stuff
    wire [4:0] fd_opcode;
    assign fd_issw = fd_opcode == 5'b00111;
    // opcode stuff for branching
    assign fd_opcode = dx_ir_in[31:27];
    wire fd_bne, fd_j, fd_jal, fd_jr, fd_bex;
    assign fd_bne = (fd_opcode == 5'b00010);
    assign fd_j = fd_opcode == 5'b00001;
    assign fd_jal = fd_opcode == 5'b00011;
    assign fd_jr = fd_opcode == 5'b00100;
    assign fd_bex = fd_opcode == 5'b10110;
    wire [4:0] fd_rs;
    assign fd_rs = dx_ir_in[21:17];
    assign ctrl_readRegA = fd_bex ? 30 : fd_rs;
    wire readRD;
    shouldReadRD CHECKRT(readRD, dx_ir_in);
    assign ctrl_readRegB = readRD ? dx_ir_in[26:22]:dx_ir_in[16:12]; // change regb to read from $rd instead of $rt if it's a sw, bne, jr, blt
    // data_writeReg assigned FROM WRITEBACK

    /****** Flush or Stall ***/
    shouldStall STALL(dostall, dx_ir, fd_ir, pw_stall); //module shouldStall(stall, dx_ir, fd_ir, pw_stall);
    // module stall(stall, dx_ir, rega, regb, fd_opcode, pw_stall);
    // stall STALL(dostall, dx_ir, ctrl_readRegA, ctrl_readRegB, fd_opcode, pw_stall); //module shouldStall(stall, dx_ir, rega, regb, fd_opcode, pw_stall);

    assign dx_ir_in = dostall | dobranch ? 0 : fd_ir;

    /****** Fast Branch ******/

    /* module fastbranch_bypass(outa, outb, 
        rega, regb, data_readRegA, data_readRegB, 
        dx_ir, xm_ir, dx_rd, xm_rd, mw_rd,
        dx_o, xm_o, mw_o ctrl_writeEnable);
   */
   fastbranch_bypass FAST_BRANCH_BYPASS(fb_by_a, fb_by_b, 
        ctrl_readRegA, ctrl_readRegB, data_readRegA, data_readRegB, 
        dx_ir, xm_ir, // dx_ir_in instead of fd_ir so it's a noop if it's
        latchRD, xm_rd, mw_rd, 
        xm_o_in, xm_o, data_writeReg, 
        q_dmem0,
        ctrl_writeEnable);

    wire [31:0] fd_t, fd_i;

    ex_T DECODE_T(fd_t, fd_ir[26:0]);
    sx DECODE_I(fd_i, fd_ir[16:0]);

    wire [31:0] fastBranchPC_rd, fastBranchPC, fast_pcN, bnePC;
    // module cla_32bit(S, c32, a, b, c0);
    cla_32bit FASTBRANCHADD(fast_pcN, fastBranchPC32, fd_pc, fd_i, 1'b0); // cla_32bit(S, c32, a, b, c0);
    // assign bnePC = (fd_opcode = 5'b00010 && ~(data_readRegA == data_readRegB)) ? fast_pcN : 
    assign fastBranchPC_rd = (fd_jr) ? fb_by_b : fast_pcN; //PC = rd if jr
    assign fastBranchPC = (fd_jal | fd_j | fd_bex) ? fd_t : fastBranchPC_rd; // PC = T if jal or j or bex

    wire doFastBranch;
    assign doFastBranch = (fd_bne && ~(fb_by_a == fb_by_b)) //bne & rd != rs
        | (fd_bex & (| fb_by_a)) //bex and rstatus != 0
        | fd_j | fd_jal | fd_jr;


    /******** EXECUTE ********/
    // dx_latch(a, b, pc_out, ir_out, data_readRegA, data_readRegB, pc_in, ir_in, clock, reset);
    dx_latch DX(dx_a, dx_b, dx_pc, dx_ir, data_readRegA, data_readRegB, fd_pc, dx_ir_in, ~clock, reset);
    assign isBLT = dx_ir[31:27] == 5'b00110;
    assign isJal = dx_ir[31:27] == 5'b00011;
    assign issw = dx_ir[31:27] == 5'b00111;
    assign islw = dx_ir[31:27] == 5'b01000;
    assign isaddi = dx_ir[31:27] == 5'b00101;
    assign isALU = dx_ir[31:27] == 5'b00000;
    assign aluOpsub = isBLT ? 5'b00001 : dx_ir[6:2]; //if blt sub, else aluop
    assign aluOp = (isaddi | issw | islw) ? 5'd0 : aluOpsub; //if I type add, else aluop

    assign shamft = dx_ir[11:7];
    sx SXImm(immediate, dx_ir[16:0]);


    alu ALU(ALU_a, ALU_b, aluOp, shamft, aluOut, isNotEqual, isLessThan, overflow);     // alu ALU(ina, inb, aluop, shmft, result, isNotEqual, isLessThan, overflow);

    // adder for PC + 1 + N (already added 1 to PC earlier)
    // ROOM FOR IMPROVEMENT: latch from before? or dont care idk
    cla_32bit PC_nxt_J(branchPC, pcbranchPC32_n_32, dx_pc, immediate, 1'b0); // cla_32bit(S, c32, a, b, c0);

    /*
    BLT ALU Logic:
    a = rs
    b = rd
    isnotequal: rs != rd
    islessthan: rs < rd
    */
    assign dobranch = isBLT & (isNotEqual & ~isLessThan);

    set_xm_inputs PREPXM(latchRD, xm_o_in, xm_im_in, overflow, aluOut, dx_pc);

    //bypass
    bypass BYPASS(selALUinA, selALUinB, selDataMem, dx_ir, xm_ir, xm_rd, ctrl_writeReg, ctrl_writeEnable);
    mux_3 ALUA(ALU_a, selALUinA, xm_o, data_writeReg, dx_a);
    mux_3 ALUB(alu_b_temp, selALUinB, xm_o, data_writeReg, dx_b);
    assign ALU_b = (isaddi | issw | islw) ? immediate : alu_b_temp;

    /*** MULTDIV ***/

    // module multdiv(data_operandA, data_operandB, ctrl_MULT, ctrl_DIV, clock, data_result, data_exception, data_resultRDY);
    assign ctrl_MULT = isALU & aluOp == 5'b00110;
    assign ctrl_DIV = isALU & aluOp == 5'b00111;
    multdiv MULTDIV(ALU_a, alu_b_temp, ctrl_MULT, ctrl_DIV, clock, p_in, data_exception, data_resultRDY);

    pw_latch PW(p, pw_rd, pw_stall, pw_done, p_in, dx_ir, data_resultRDY, data_exception, ~clock, reset);
    
    /******** MEMORY ********/
    assign xm_im_in = ctrl_MULT | ctrl_DIV ? 0 : dx_ir;
    m_latch XM(xm_o, xm_b, xm_ir, xm_rd, xm_o_in, alu_b_temp, xm_im_in, latchRD, ~clock, reset); // module m_latch(o, bd, ir_out, rdout, oin, bdin, ir_in, rdin, clock, clear);

    assign xm_aluOp = xm_ir[6:2];

    assign address_dmem = xm_o;                             // O: The address of the data to get or put from/to dmem
    assign data = selDataMem ? xm_b : data_writeReg;                                     // O: The data to write to dmem
    assign wren = (xm_ir[31:27] == 5'b00111);                   // O: Write enable for dmem... only 1 if sw

    /******** WRITEBACK ********/
    m_latch MW(mw_o, mw_d, mw_ir, mw_rd, xm_o, q_dmem0, xm_ir, xm_rd, ~clock, reset);
    assign ctrl_writeReg =  pw_done ? pw_rd : mw_rd;

    assign mw_opcode = mw_ir[31:27];
    
    assign writeback_islw = (mw_opcode == 5'b01000);
    assign writeback_isALUOp = (mw_opcode == 5'b0000);
    assign writeback_isJAL = (mw_opcode == 5'b00011);
    assign writeback_isSetx = (mw_opcode == 5'b10101);

    wire [31:0] data_writeReg_prePW;
    assign data_writeReg_prePW = writeback_islw ? mw_d : mw_o;
    assign data_writeReg = pw_done ? p : data_writeReg_prePW;
    assign ctrl_writeEnable = writeback_islw | writeback_isALUOp | writeback_isJAL | writeback_isSetx | (mw_opcode == 5'b00101); //last one is addi

    /********** PC STUFF ********/
    wire [32:0] pc_in_noreset;
    assign pc_in_noreset = dobranch ? branchPC : pc_nxt;
    // assign pc_in = reset ? 32'd0 : pc_in_noreset;
    // DO WE SET PC TO 0 IF RESET? THIS MAKES MY FIRST INSTR LONG --> POTENTIAL ERROR IF I ADD A REGISTER TO ITSELF BC IT WILL DO IT TWICE? 
    
    assign pc_in = doFastBranch ? fastBranchPC : pc_in_noreset; // not resetting pc... fast branch

    //TODO:

    /******** NOTES ********/
    //stall: disable write enable for pc and fd latch... write enable for everything else is 1
	/************************************************ END CODE ***********************************************/

endmodule
