`include "sr_cpu.svh"
module sr_register_file
(
  input clk,
  input rst,
  input [ 4:0] a0,
  input [ 4:0] a1,
  input [ 4:0] a2,
  input [ 4:0] a3,
  output [31:0] rd0,
  output [31:0] rd1,
  output [31:0] rd2,
  input [31:0] wd3,
  input we3
);

  localparam REGISTER_FILE_LENGTH = 32;

  logic [31:0] rf [0:31];
  assign rd0 = (a0 != 0) ? rf [a0] : 32'b0;
  assign rd1 = (a1 != 0) ? rf [a1] : 32'b0;
  assign rd2 = (a2 != 0) ? rf [a2] : 32'b0;

always_ff @ (posedge clk or posedge rst) begin
  if (rst) begin
    for (int i=0; i < REGISTER_FILE_LENGTH; i++) begin
      rf[i] <= '0;
    end
  end else begin
    if(we3) rf [a3] <= wd3;
  end
end
endmodule
