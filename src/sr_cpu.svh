//
//  schoolRISCV - small RISC-V CPU
//
//  Originally based on Sarah L. Harris MIPS CPU
//  & schoolMIPS project.
//
//  Copyright (c) 2017-2020 Stanislav Zhelnio & Aleksandr Romanov.
//
//  Modified in 2024 by Yuri Panchul & Mike Kuskov
//  for systemverilog-homework project.
//

`ifndef SR_CPU_SVH
`define SR_CPU_SVH

// ALU commands

`define ALU_ADD     3'b000
`define ALU_OR      3'b001
`define ALU_SRL     3'b010
`define ALU_SLTU    3'b011
`define ALU_SUB     3'b100
`define ALU_MUL		  3'b101

// Instruction opcode

`define RVOP_ADDI   7'b0010011
`define RVOP_BEQ    7'b1100011
`define RVOP_LUI    7'b0110111
`define RVOP_BNE    7'b1100011
`define RVOP_ADD    7'b0110011
`define RVOP_OR     7'b0110011
`define RVOP_SRL    7'b0110011
`define RVOP_SLTU   7'b0110011
`define RVOP_SUB    7'b0110011
`define RVOP_MUL    7'b0110011
`define RVOP_JAL    7'b1101111
`define RVOP_SW     7'b0100011
`define RVOP_LW     7'b0000011
`define RVOP_AUIPC  7'b0010111

// Instruction funct3

`define RVF3_ADDI   3'b000
`define RVF3_BEQ    3'b000
`define RVF3_BNE    3'b001
`define RVF3_ADD    3'b000
`define RVF3_OR     3'b110
`define RVF3_SRL    3'b101
`define RVF3_SLTU   3'b011
`define RVF3_SUB    3'b000
`define RVF3_MUL    3'b000
`define RVF3_SW     3'b010
`define RVF3_LW     3'b010
`define RVF3_ANY    3'b???

// Instruction funct7

`define RVF7_ADD    7'b0000000
`define RVF7_OR     7'b0000000
`define RVF7_SRL    7'b0000000
`define RVF7_SLTU   7'b0000000
`define RVF7_SUB    7'b0100000
`define RVF7_MUL    7'b0000001
`define RVF7_ANY    7'b???????

// PC Branch source Gray Coding
`define PC_BRANCH_B 2'b00
`define PC_BRANCH_J 2'b10
`define PC_BRANCH_U 2'b11

// Result source Gray Coding
`define RES_SRC_ALU   2'b00
`define RES_SRC_MEM   2'b01
`define RES_SRC_JAL   2'b11
`define RES_SRC_LUI   2'b10
`define RES_SRC_AUIPC 2'b11

`endif  // `ifndef SR_CPU_SVH
