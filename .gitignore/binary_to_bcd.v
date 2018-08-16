`timescale 1ns / 1ps

module binary_to_bcd(s,binary,bcd);
    input s;
    input [15:0]binary;
    output reg [16:0]bcd;
    reg [31:0]tab;
    integer x;
    
    always@(binary,s)
    begin
        tab[31:16] = 16'b0; 
        tab[15:0] = binary;     //loading the binary number into the shifting table
        
        //start the loop of 16 shifts
        for (x=0; x<16; x = x+1)
        begin
            if (tab[19:16] >= 5)    //bcd ones digit ensure only 0-9
                tab[19:16] = tab[19:16] + 3;
            if (tab[23:20] >= 5)    //bcd tens digit ensure only 0-9
                tab[23:20] = tab[23:20] + 3;
            if (tab[27:24] >= 5)    //bcd hundreds digit ensure only 0-9
                tab[27:24] = tab[27:24] + 3;
            if (tab[31:28] >= 5)    //bcd thousands digit ensure only 0-9
                tab[31:28] = tab[31:28] + 3;
            else tab = tab << 1;     //shift left one
        end
        
        bcd = {s,tab[31:16]};    //assign the bcd number
    end 
   
endmodule
