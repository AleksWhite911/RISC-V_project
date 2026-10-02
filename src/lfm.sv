// module lfm (
//   input clk,
//   input rst_n,
//   input [31:0] lfm_coef,
//   input [31:0] time_limit_lfm,
//   output logic [15:0] lfm_out
// );

//   logic [31:0] counter_lfm;
//   logic front_detect;





//   always_ff @(posedge clk) begin
//     if (~rst_n) begin
//       lfm_out <= '0;
//       counter_lfm <= '0;
//       front_detect <= '0;
//     end else begin
//       if (lfm_en && (counter < time_limit_lfm) ) begin
//         lfm_out <= lfm_out + lfm_coef;
//       end else begin
//         lfm_out <= '0;
//       end
//     end
//   end






// endmodule