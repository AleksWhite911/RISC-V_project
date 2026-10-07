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

  output logic ADD_INSTR,
  output logic OR_INSTR,
  output logic SRL_INSTR,
  output logic SLTU_INSTR,
  output logic SUB_INSTR,
  output logic MUL_INSTR,
  output logic LW_INSTR,
  output logic SW_INSTR,
  output logic ADDI_INSTR,
  output logic LUI_INSTR,
  output logic BEQ_INSTR,
  output logic BNE_INSTR,
  output logic JAL_INSTR    
);

  logic [31:0] imAddr, imData;
  logic enable_memory = 1'b1;

  assign imAddr_debug = imAddr;
  assign ImData_debug = imData;


    instruction_rom # (.SIZE (1024)) rom
    (
      .clk(clk),
      .en(enable_memory),
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

    //Periphery module's
    .gpio_port_a(gpio_port_a),
    .gpio_port_b(gpio_port_b),

    //DDS_1
    .i_component(i_component),
    .q_component(q_component),

    //DDS_2
    .i_component_2(i_component_2),
    .q_component_2(q_component_2),


    .ADD_INSTR  ( ADD_INSTR   ),
    .OR_INSTR   ( OR_INSTR    ),
    .SRL_INSTR  ( SRL_INSTR   ),
    .SLTU_INSTR ( SLTU_INSTR  ),
    .SUB_INSTR  ( SUB_INSTR   ),
    .MUL_INSTR  ( MUL_INSTR   ),
    .LW_INSTR   ( LW_INSTR    ),
    .SW_INSTR   ( SW_INSTR    ),
    .ADDI_INSTR ( ADDI_INSTR  ),
    .LUI_INSTR  ( LUI_INSTR   ),
    .BEQ_INSTR  ( BEQ_INSTR   ),
    .BNE_INSTR  ( BNE_INSTR   ),
    .JAL_INSTR  ( JAL_INSTR   )


  );

endmodule