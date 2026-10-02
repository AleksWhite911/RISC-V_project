/////////////////////////////////////////////////////////////////
// Name File          : lut.v                                  //
// Autor              : Ren_Ashbell                            //
// Company            :                                        //
// Description        : lut(look_up_table_sin)                 //
// Start design       : 27.01.23                               //
// Last revision      : 30.01.23                               //
/////////////////////////////////////////////////////////////////

module lut(
	input [(16-1):0] addr_a, addr_b,
	input clk,
	output reg[(15-1):0] q_a, q_b
	);
	
	//localparam data_width = 16;
	//localparam addr_width = 15;
	
	reg [16-1:0] lut[2**15-1:0];
	
	initial begin
		$readmemb("lut.txt", lut);
	end
	
	always_comb
	begin
		q_a = lut[addr_a];
		q_b = lut[addr_b];
	end
endmodule