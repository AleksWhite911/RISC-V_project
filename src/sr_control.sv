`include "sr_cpu.svh"

module sr_control
(
    input        [6:0]  cmdOp,
    input        [2:0]  cmdF3,
    input        [6:0]  cmdF7,
    input               aluZero,
    output logic        pcSrc,
    output logic        regWrite,
    output logic        aluSrc,
    output logic        MemWrite,
    output logic [2:0]  ResultSrc,
    output logic [2:0]  aluControl,
    output logic [1:0]  immSrc,
    output logic [1:0]  branch_src,

    //DEBUG PORTS
    output logic [13:0] decode_instr                               


);
    logic          branch;
    logic          condZero;
    logic          jal;

  assign  pcSrc = branch & (aluZero == condZero) | jal;

    always_comb
    begin
        branch_src  = `PC_BRANCH_B;
        branch      =         1'b0;
        condZero    =         1'b0;
        regWrite    =         1'b0;
        aluSrc      =         1'b0;
        MemWrite    =         1'b0;
        ResultSrc   = `RES_SRC_ALU;
        immSrc      =           '0;
        jal         =           '0;
        aluControl  =     `ALU_ADD;

        decode_instr =          '0;

        casez ({ cmdF7, cmdF3, cmdOp })
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin regWrite = 1'b1; aluControl = `ALU_ADD;  decode_instr = 14'd1; end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin regWrite = 1'b1; aluControl = `ALU_OR;   decode_instr = 14'd2; end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin regWrite = 1'b1; aluControl = `ALU_SRL;  decode_instr = 14'd3; end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin regWrite = 1'b1; aluControl = `ALU_SLTU; decode_instr = 14'd4; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin regWrite = 1'b1; aluControl = `ALU_SUB;  decode_instr = 14'd5; end
            { `RVF7_MUL,  `RVF3_MUL,  `RVOP_MUL  } : begin regWrite = 1'b1; aluControl = `ALU_MUL;  decode_instr = 14'd6; end
            { `RVF7_ANY,  `RVF3_LW,   `RVOP_LW   } : begin regWrite = 1'b1; ResultSrc = `RES_SRC_MEM; aluSrc = 1'b1; immSrc = '0; aluControl = `ALU_ADD; decode_instr = 14'd7;  end
            { `RVF7_ANY,  `RVF3_SW,   `RVOP_SW   } : begin MemWrite = 1'b1; aluControl = `ALU_ADD; aluSrc = 1'b1; immSrc = 2'b01; decode_instr = 14'd8; end
            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; decode_instr = 14'd9; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin regWrite = 1'b1; ResultSrc = `RES_SRC_LUI; decode_instr = 14'd10; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_AUIPC} : begin regWrite = 1'b1; ResultSrc = `RES_SRC_AUIPC; decode_instr = 14'd11; end
            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUB; decode_instr = 14'd12; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin branch = 1'b1; aluControl = `ALU_SUB; decode_instr = 14'd13; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_JAL  } : begin branch = 1'b1; branch_src = `PC_BRANCH_J; ResultSrc = `RES_SRC_JAL; regWrite = 1'b1; aluControl = `ALU_ADD; jal = 1'b1; decode_instr = 14'd14; end

        endcase
    end

endmodule
