`include "sr_cpu.svh"

module sr_cpu
(
    input           clk,      // clock
    input           rst,      // reset

    output  [31:0]  imAddr,   // instruction memory address
    input   [31:0]  imData,   // instruction memory data

    input   [ 4:0] regAddr,  // debug access reg address
    output  [31:0] regData,   // debug access reg data
    output [15:0] i_component, q_component, i_component_2, q_component_2,
    output [31:0] gpio_port_a, gpio_port_b,

    //DEBUG PORTS CONTROL
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
    // control wires

    wire        aluZero;
    wire        pcSrc;
    wire        regWrite;
    wire        aluSrc;
    wire [2:0]  aluControl;
    wire [1:0]  branch_src;
    wire [2:0]  ResultSrc;

    // program counter
    logic [31:0] pcBranch;
    wire [31:0] pc;
    wire [31:0] pcPlus4  = pc + (32'd4);
    wire [31:0] pcNext   = pcSrc ? pcBranch : pcPlus4;


    logic [31:0] ResultSrcMux;
    wire [31:0] dds_freq_control, dds_freq_control_2;

    logic reg_write_w, MemWrite;
    logic [4:0] rs1_reg, rs2_reg, rd_reg;
    logic [31:0] wd3_reg;
    logic [31:0] ReadData, ImmExt;
    //for DDS
    logic [15:0] lfm_coef = '0;

    register_with_rst r_pc (clk, rst, pcNext, pc);

    // program memory access

    assign imAddr = pc >> 2;
    wire [31:0] instr = imData;



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


    always_comb begin
      case (branch_src)
        `PC_BRANCH_B: begin
          pcBranch = pc + immB;
        end

        `PC_BRANCH_J: begin
          pcBranch = pc + immJ;
        end

        default: begin
          pcBranch = pc + 32'd4;
        end
      endcase
    end



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

    wire [31:0] rd0;  //FOR DEBUG!
    wire [31:0] rd1;
    wire [31:0] rd2;
    wire [31:0] wd3;

    sr_register_file rf
    (
        .clk        ( clk         ),
        .rst        ( rst         ),
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

    always_comb begin
      case (ResultSrc)
        `RES_SRC_ALU: begin
          ResultSrcMux = aluResult;
        end

        `RES_SRC_MEM: begin
          ResultSrcMux = ReadData;
        end

        `RES_SRC_JAL: begin
          ResultSrcMux = pcPlus4;
        end

        `RES_SRC_LUI: begin
          ResultSrcMux = immU;
        end

        `RES_SRC_AUIPC: begin
          ResultSrcMux = pc + immU;
        end

        default: begin
          ResultSrcMux = aluResult;
        end
      endcase
    end

    assign wd3 = ResultSrcMux;

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

    angle_to_amp dds (
      .freq_control(dds_freq_control),
      .data_clk(clk),
      .enable(1'b1),
      .I(i_component),
      .Q(q_component),
      .lfm_coef(lfm_coef),
      .reset_fpga(rst)
    );

    angle_to_amp dds_2 (
      .freq_control(dds_freq_control_2),
      .data_clk(clk),
      .enable(1'b1),
      .I(i_component_2),
      .Q(q_component_2),
      .lfm_coef(lfm_coef),
      .reset_fpga(rst)
    );

    // control

    sr_control sm_control
    (
        .cmdOp      ( cmdOp           ),
        .cmdF3      ( cmdF3           ),
        .cmdF7      ( cmdF7           ),
        .aluZero    ( aluZero         ),
        .pcSrc      ( pcSrc           ),
        .regWrite   ( regWrite        ),
        .aluSrc     ( aluSrc          ),
        .branch_src ( branch_src      ),
        .aluControl ( aluControl      ),
        .MemWrite   ( MemWrite        ),
        .ResultSrc  ( ResultSrc       ),
        .immSrc     ( immSrc          ),
        .ADD_INSTR  ( ADD_INSTR       ),
        .OR_INSTR   ( OR_INSTR        ),
        .SRL_INSTR  ( SRL_INSTR       ),
        .SLTU_INSTR ( SLTU_INSTR      ),
        .SUB_INSTR  ( SUB_INSTR       ),
        .MUL_INSTR  ( MUL_INSTR       ),
        .LW_INSTR   ( LW_INSTR        ),
        .SW_INSTR   ( SW_INSTR        ),
        .ADDI_INSTR ( ADDI_INSTR      ),
        .LUI_INSTR  ( LUI_INSTR       ),
        .BEQ_INSTR  ( BEQ_INSTR       ),
        .BNE_INSTR  ( BNE_INSTR       ),
        .JAL_INSTR  ( JAL_INSTR       )
    );

    // debug register access

    assign regData = (regAddr != '0) ? rd0 : pc;

endmodule
