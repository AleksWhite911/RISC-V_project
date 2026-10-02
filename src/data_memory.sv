module data_memory
#(
    parameter SIZE = 1024
)
(
    input clk, we,
    input [31:0] a, 
    input [31:0] wd,
    output logic [31:0] dds_freq_control,
    output logic [31:0] dds_freq_control_2,
    output logic [31:0] gpio_port_a,
    output logic [31:0] gpio_port_b,
    output logic [31:0] rd
);


  logic [31:0] ram [0:SIZE-1];
  logic [$clog2(SIZE)-1:0] memory_address;

  assign memory_address = a[$clog2(SIZE)-1:2];
  assign rd                 = ram[memory_address];
  assign dds_freq_control   = ram[0];
  assign dds_freq_control_2 = ram[1];
  assign gpio_port_a        = ram[2];
  assign gpio_port_b        = ram[3];

  
  always_ff @ (posedge clk)
    if (we) ram[memory_address] <= wd;


endmodule
