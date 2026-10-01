`include "sr_cpu.svh"

module sr_cpu
(
    input           clk,      // clock
    input           rst,      // reset

    output  [31:0]  imAddr,   // instruction memory address
    input   [31:0]  imData,   // instruction memory data

    input   [ 4:0]  regAddr,  // debug access reg address
    output  [31:0]  regData,   // debug access reg data
    output [15:0] i_component, q_component, i_component_2, q_component_2,
    output [31:0] gpio_port_a, gpio_port_b
);
    // control wires

    wire        aluZero;
    wire        pcSrc;
    wire        regWrite;
    wire        aluSrc;
    wire        wdSrc;
    wire  [2:0] aluControl;
    wire jal;

    // instruction decode wires

    wire [ 6:0] cmdOp;
    wire [ 4:0] rd;
    wire [ 2:0] cmdF3;
    wire [ 4:0] rs1;
    wire [ 4:0] rs2;
    wire [ 6:0] cmdF7;
    wire [31:0] immI;
    wire [31:0] immB;
    wire [31:0] immU;
    wire [31:0] immS;
    wire [31:0] immJ;

    // program counter

    wire [31:0] pc;
    //wire [31:0] pcBranch = pc + immB;
    logic [31:0] pcBranch;
    wire [31:0] pcPlus4  = pc + 32'd4;
    wire [31:0] pcNext   = pcSrc ? pcBranch : pcPlus4;

     always_comb begin
      if (jal)
        pcBranch = pc + immJ;
      else
        pcBranch = pc + immB;
    end

    wire [31:0] dds_freq_control, dds_freq_control_2;

    logic reg_write_w, ResultSrc, ResultSrcE, MemWrite;
    logic [4:0] rs1_reg, rs2_reg, rd_reg;
    logic [31:0] wd3_reg;
    logic [31:0] ReadData, Result, ImmExt;

    register_with_rst r_pc (clk, rst, pcNext, pc);

    // program memory access

    assign imAddr = pc >> 2;
    wire [31:0] instr = imData;

    // instruction decode

    sr_decode id
    (
        .instr      ( instr       ),
        .cmdOp      ( cmdOp       ),
        .rd         ( rd          ),
        .cmdF3      ( cmdF3       ),
        .rs1        ( rs1         ),
        .rs2        ( rs2         ),
        .cmdF7      ( cmdF7       ),
        .immI       ( immI        ),
        .immB       ( immB        ),
        .immU       ( immU        ),
        .immS       ( immS        ),
        .immJ       ( immJ        )
    );

    // register file

    wire [31:0] rd0;
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wd3;

    sr_register_file rf
    (
        .clk        ( clk         ),
        .a0         ( regAddr     ),
        .a1         ( rs1         ),
        .a2         ( rs2         ),
        .a3         ( rd          ),
        .rd0        ( rd0         ),
        .rd1        ( rd1         ),
        .rd2        ( rd2         ),
        .wd3        ( wd3         ),
        .we3        ( regWrite    )
    );

    // alu

    wire [31:0] srcB = aluSrc ? ImmExt : rd2;
    wire [31:0] aluResult;
    wire [2:0] op_reg;
    wire [1:0] immSrc;

    always_comb
      if (~ResultSrc) Result = aluResult;
      else Result = ReadData;

    always_comb
      case (immSrc)
        '0     : ImmExt = immI;
        2'b01  : ImmExt = immS;
        2'b10  : ImmExt = immB;
        default: ImmExt = immI;
    endcase

    sr_alu alu
    (
        .clk        ( clk         ),
        .rst        ( rst         ),
        .srcA       ( rd1         ),
        .srcB       ( srcB        ),
        .oper       ( aluControl  ),
        .zero       ( aluZero     ),
        .result     ( aluResult   )
    );

    data_memory data_memory
    (
      .clk(clk),
      .we(MemWrite),
      .a(aluResult),
      .wd(rd2),
      .rd(ReadData),
      .dds_freq_control(dds_freq_control),
      .dds_freq_control_2(dds_freq_control_2),
      .gpio_port_a(gpio_port_a),
      .gpio_port_b(gpio_port_b)
    );
      
    assign wd3 = wdSrc ? immU : Result;

    angle_to_amp dds (
      .freq_control(dds_freq_control),
      .data_clk(clk),
      .enable(1'b1),
      .I(i_component),
      .Q(q_component),
      .reset_fpga(rst)
    );

    angle_to_amp dds_2 (
      .freq_control(dds_freq_control_2),
      .data_clk(clk),
      .enable(1'b1),
      .I(i_component_2),
      .Q(q_component_2),
      .reset_fpga(rst)
    );

    // control

    sr_control sm_control
    (
        .cmdOp      ( cmdOp       ),
        .cmdF3      ( cmdF3       ),
        .cmdF7      ( cmdF7       ),
        .aluZero    ( aluZero     ),
        .pcSrc      ( pcSrc       ),
        .regWrite   ( regWrite    ),
        .aluSrc     ( aluSrc      ),
        .wdSrc      ( wdSrc       ),
        .jal        ( jal         ),
        .aluControl ( aluControl  ),
        .MemWrite   ( MemWrite    ),
        .ResultSrc  ( ResultSrc   ),
        .immSrc     ( immSrc      )
    );

    // debug register access

    assign regData = (regAddr != '0) ? rd0 : pc;

endmodule
