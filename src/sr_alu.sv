`include "sr_cpu.svh"

module sr_alu
(   input               clk,
    		input               rst,
    		input        [31:0] srcA,
    		input        [31:0] srcB,
    		input        [ 2:0] oper,
    		output              zero,
   		output logic [31:0] result
);
   	   		always_comb
       		case (oper)
            default   : result =  srcA +  srcB;
            `ALU_ADD  : result =  srcA +  srcB;
            `ALU_OR   : result =  srcA |  srcB;
            `ALU_SRL  : result =  srcA >> srcB [4:0];
            `ALU_SLTU : result = (srcA <  srcB) ? 32'd1 : 32'd0;
            `ALU_SUB  : result =  srcA -  srcB;
            `ALU_MUL  : result =  srcA *  srcB;
        		endcase      
   	  		assign zero = (result == '0);
endmodule
