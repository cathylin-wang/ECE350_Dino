// module shouldStall(stall, dx_ir, fd_ir, pw_stall);
//     input[31:0] dx_ir, fd_ir;
//     input pw_stall;
//     output stall;

//     wire [4:0] dx_opcode, fd_opcode, dx_rd;
//     assign dx_opcode = dx_ir[31:27];
//     assign fd_opcode = fd_ir[31:27];
//     assign dx_rd = dx_ir[26:22]; // only care about if dx is load word -> always check for rd, don't have to worry about rstatus for overflow
//     wire readRD;

//     assign stall = 
//     pw_stall | 
//     ((dx_opcode == 5'b01000) //load 
//         & ((fd_ir[21:17] == dx_rd) //fd_rsa = rs
//         || fd_ir[16:12] == dx_rd //fd_rsb = rt
//         && fd_opcode != 5'b00111)); //opcode = store
//     // lw --> sw is fixed with bypass
//     // lw --> blt or bne? do we fix here by replaceing rt with rd?
//     // blt/bne: still stall: use ctrl read reg a & b ---> put that logic into a module and reuse logic


// endmodule

module shouldStall(stall, dx_ir, fd_ir, pw_stall);
    input[31:0] dx_ir, fd_ir;
    input pw_stall;
    output stall;

    wire [4:0] dx_opcode, fd_opcode, dx_rd;
    assign dx_opcode = dx_ir[31:27];
    assign fd_opcode = fd_ir[31:27];
    assign dx_rd = dx_ir[26:22]; // only care about if dx is load word -> always check for rd, don't have to worry about rstatus for overflow

    wire[4:0] rs, rt;
    wire readRD;
    shouldReadRD CHECKRT(readRD, fd_ir);
    assign rt = readRD ? fd_ir[26:22] : fd_ir[16:12]; // change regb to read from $rd instead of $rt if it's a sw, bne, jr, blt
    
    assign rs = fd_opcode == 5'b10110 ? 30 : fd_ir[21:17];

    assign stall = 
    pw_stall | 
    ((dx_opcode == 5'b01000) //load 
        & ((rs == dx_rd) //fd_rsa = rs
        || rt == dx_rd //fd_rsb = rt
        && fd_opcode != 5'b00111)); //opcode = store
    // lw --> sw is fixed with bypass
    // lw --> blt or bne? do we fix here by replaceing rt with rd?
    // blt/bne: still stall: use ctrl read reg a & b ---> put that logic into a module and reuse logic


endmodule

