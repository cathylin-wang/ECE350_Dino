module booth_ctrl(select_dontadd, select_addsub, prodLSB);

    input [2:0] prodLSB;
    output select_dontadd;
    output[1:0] select_addsub;

    // DO NOTHING IF: 000 or 111
    // select_dontadd = 1, select_addsub = don't care
    wire [2:0] notprodLSB;
    assign notprodLSB = ~ prodLSB;
    assign select_dontadd = (prodLSB[2] & prodLSB[1] & prodLSB[0]) | (notprodLSB[2] & notprodLSB[1] & notprodLSB[0]) ;
    

    //select_dontadd = 0 for the rest:

    // add M (select_addsub = 00) if 010, 001
    //add M<<1 (select_addsub = 01) if 011
    // sub M (select_addsub = 10) if 110, 101

    assign select_addsub[1] = prodLSB[2];
    assign select_addsub[0] = (prodLSB[1] & prodLSB[0]) | (notprodLSB[1] & notprodLSB[0]);   


endmodule