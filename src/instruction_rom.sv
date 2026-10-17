`include "sr_cpu.svh"
module instruction_rom
#(
    parameter SIZE = 64
)
(
    input         clk,
    input         rst,
    input  [31:0] a,
    input         stall,
    output logic [31:0] rd


);  (* rom_style = "block" *)
    logic [31:0] rom [0:SIZE - 1];

    always_ff @(posedge clk) begin
      if (rst) begin
        rd <= 32'h00000013;
      end else begin
        if (~stall) begin
          rd <= rom[a];
        end else begin
          rd <= 32'h00000013;
        end
      end
    end

    initial $readmemh ("program.hex", rom);

endmodule
