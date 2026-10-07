module instruction_rom
#(
    parameter SIZE = 64
)
(
    input         clk,
    input  [31:0] a,
    input         en,
    output logic [31:0] rd
);
    reg [31:0] rom [0:SIZE - 1];
    // assign rd = rom [a];


    always_ff @(posedge clk) begin
      if (en) begin
        rd <= rom [a];
      end
    end

    initial $readmemh ("program.hex", rom);

endmodule
