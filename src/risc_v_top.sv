`include "sr_cpu.svh"
module risc_v_top (

  //clock and rst
  input clk,
  input rst,

  //Gpio block
  output [31:0] gpio_port_a,
  output [31:0] gpio_port_b,

  //DDS channel 1 output
  output [15:0] i_component, q_component,

  //DDS channel 2 output
  output [15:0] i_component_2, q_component_2,

  //signals for debug
  input [4:0] regAddr,
  output [31:0] regData,

  output [31:0] imAddr_debug,
  output [31:0] ImData_debug,

  `ifdef DEBUG
      //Debug ports register file
      output [31:0] rd_0_debug,
      output [31:0] rd_1_debug,
      output [31:0] wd_debug,


      //Signals for execute instruction
      output regWrite_debug,
      output [2:0] aluControl_debug,
  `endif


  output [13:0] decode_instr 
);

  logic [31:0] imAddr, imData;
  wire stall;

  assign imAddr_debug = imAddr;
  assign ImData_debug = imData;


    instruction_rom # (.SIZE (1024)) rom
    (
      .clk(clk),
      .rst(rst),
      .stall(stall),
      .a(imAddr),
      .rd(imData)
    );

  sr_cpu risc_v_cpu (
    .clk(clk),
    .rst(rst),
    .imAddr(imAddr),
    .imData(imData),
    .regAddr(regAddr),
    .regData(regData),
    .stall(stall),

    //Periphery module's
    .gpio_port_a(gpio_port_a),
    .gpio_port_b(gpio_port_b),

    //DDS_1
    .i_component(i_component),
    .q_component(q_component),

    //DDS_2
    .i_component_2(i_component_2),
    .q_component_2(q_component_2),

    `ifdef DEBUG
      .rd_0_debug(rd_0_debug),
      .rd_1_debug(rd_1_debug),
      .wd_debug(wd_debug),
      .regWrite_debug(regWrite_debug),
      .aluControl_debug(aluControl_debug),
    `endif

    .decode_instr(decode_instr)


  );

endmodule