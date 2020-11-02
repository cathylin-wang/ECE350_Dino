module mul(data_result, data_resultRDY, data_exception, multiplier, multiplicand, ctrl_MULT, clock, ctrl_DIV);

    input signed [31:0] multiplier, multiplicand;
    input ctrl_MULT, clock, ctrl_DIV;

    output signed[31:0] data_result;
    output data_exception, data_resultRDY;
    
    wire data_resultRDY_hold;
    //counter
    counter ctr(data_resultRDY, data_resultRDY_hold, clock, ctrl_MULT, ctrl_DIV);

    // prod = product (read from reg) -- unsure if i have to initialize?
    // prod_sft = product shifted by 2 (write to reg)
    wire signed [64:0] prod, prod_shft, prod_mod, initialReg;
    
    // at the beginning: reset product register
    assign initialReg[32:1] = multiplier;
    assign initialReg[0] = 1'b0; //implicit 0;
    assign initialReg[64:33] = 0; //clear high reg
    
    assign prod_shft = ctrl_MULT ? initialReg : prod_mod >>> 2;

    wire signed [31:0] M;
    assign M = multiplicand;
    // QUESTION: I feel like I should be saving M to a register in case it changes thru/o my operations but it seems to be delaying? or like not working
    // register multiplicand_reg(M, multiplicand, clock, ctrl_MULT, 1'b0);    
    
    // PRODUCT REGISTER
    register65 productregister(prod, prod_shft, clock, ~data_resultRDY | ~data_resultRDY_hold, 1'b0);
    
    /// CTRL
    wire [1:0] select_addsub;
    wire select_dontadd;
    booth_ctrl getCtrl(select_dontadd, select_addsub, prod[2:0]);
    
    // All the adders/subtractors     ----     module cla_32bit(S, c32, a, b, c0);
    wire signed [31:0] M_shft, p_addM, p_add2M, p_subM, p_sub2M;
    assign M_shft = M<<1;
    cla_32bit addM(p_addM, c32, M, prod[64:33], 1'b0);
    cla_32bit add2M(p_add2M, c32, M_shft, prod[64:33], 1'b0);
    cla_32bit subM(p_subM, c32, ~M, prod[64:33], 1'b1);
    cla_32bit sub2M(p_sub2M, c32, ~M_shft, prod[64:33], 1'b1);

    // 4:1mux into product high reg
    wire signed [31:0] prod_added;
    mux_4 addToProd(prod_added, select_addsub, p_addM, p_add2M, p_subM, p_sub2M); // select_addsub

    //2:1 mux add anything at all
    assign prod_mod[64:33] = select_dontadd ? prod[64:33] : prod_added;
    assign prod_mod[32:0] = prod[32:0];

    // data_exception
    wire noOverflowNeg, noOverflowPos;
    assign noOverflowNeg = prod[64] & prod[63] & prod[62] & prod[61] & prod[60] & prod[59] & prod[58] & prod[57] & prod[56] & prod[55] & prod[54] & prod[53] & prod[52] & prod[51] & prod[50] & prod[49] & prod[48] & prod[47] & prod[46] & prod[45] & prod[44] & prod[43] & prod[42] & prod[41] & prod[40] & prod[39] & prod[38] & prod[37] & prod[36] & prod[35] & prod[34] & prod[33] & prod[32];
    wire [65:0] notprod;
    assign notprod = ~prod;
    assign noOverflowPos = notprod[64] & notprod[63] & notprod[62] & notprod[61] & notprod[60] & notprod[59] & notprod[58] & notprod[57] & notprod[56] & notprod[55] & notprod[54] & notprod[53] & notprod[52] & notprod[51] & notprod[50] & notprod[49] & notprod[48] & notprod[47] & notprod[46] & notprod[45] & notprod[44] & notprod[43] & notprod[42] & notprod[41] & notprod[40] & notprod[39] & notprod[38] & notprod[37] & notprod[36] & notprod[35] & notprod[34] & notprod[33] & notprod[32];
    assign data_exception = ~(noOverflowNeg | noOverflowPos);

    // assign result to low reg
    assign data_result = prod[32:1];

endmodule