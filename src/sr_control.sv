`include "sr_cpu.svh"

module sr_control
(
    input        [ 6:0] cmdOp,
    input        [ 2:0] cmdF3,
    input        [ 6:0] cmdF7,
    input               aluZero,
    output logic        pcSrc,
    output logic        regWrite,
    output logic        aluSrc,
    output logic [ 1:0] wdSrc,
    output logic        jal,
    output logic        MemWrite,
    output logic        ResultSrc,
    output logic [ 2:0] aluControl,
    output logic [ 1:0] immSrc,

    //DEBUG PORTS
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
    logic          branch;
    logic          condZero;
    //assign pcSrc = branch & (aluZero == condZero);

    always_comb begin
      if (jal)
        pcSrc = 1'b1;
      else if (branch & (aluZero == condZero))
        pcSrc = 1'b1;
      else
        pcSrc = 1'b0;
    end
    always_comb
    begin
        jal         = 1'b0;
        branch      = 1'b0;
        condZero    = 1'b0;
        regWrite    = 1'b0;
        aluSrc      = 1'b0;
        wdSrc       = 1'b0;
        MemWrite    = 1'b0;
        ResultSrc   = 1'b0;
        immSrc      =   '0;

        aluControl  = `ALU_ADD;
        //DEBUG PORTS
        ADD_INSTR   =   '0;
        OR_INSTR    =   '0;
        SRL_INSTR   =   '0;
        SLTU_INSTR  =   '0;
        SUB_INSTR   =   '0;
        MUL_INSTR   =   '0;
        LW_INSTR    =   '0;
        SW_INSTR    =   '0;
        ADDI_INSTR  =   '0;
        LUI_INSTR   =   '0;
        BEQ_INSTR   =   '0;
        BNE_INSTR   =   '0;
        JAL_INSTR   =   '0;

        casez ({ cmdF7, cmdF3, cmdOp })
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin regWrite = 1'b1; aluControl = `ALU_ADD;  ADD_INSTR  = 1'b1; end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin regWrite = 1'b1; aluControl = `ALU_OR;   OR_INSTR   = 1'b1; end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin regWrite = 1'b1; aluControl = `ALU_SRL;  SRL_INSTR  = 1'b1; end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin regWrite = 1'b1; aluControl = `ALU_SLTU; SLTU_INSTR = 1'b1; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin regWrite = 1'b1; aluControl = `ALU_SUB;  SUB_INSTR  = 1'b1; end
            { `RVF7_MUL,  `RVF3_MUL,  `RVOP_MUL  } : begin regWrite = 1'b1; aluControl = `ALU_MUL;  MUL_INSTR  = 1'b1; end
            { `RVF7_ANY,  `RVF3_LW,   `RVOP_LW   } : begin regWrite = 1'b1; ResultSrc = 1'b1; aluSrc = 1'b1; immSrc = '0; aluControl = `ALU_ADD; LW_INSTR = 1'b1;  end
            { `RVF7_ANY,  `RVF3_SW,   `RVOP_SW   } : begin MemWrite = 1'b1; aluControl = `ALU_ADD; aluSrc = 1'b1; immSrc = 2'b01; SW_INSTR = 1'b1; end
            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; ADDI_INSTR = 1'b1; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin regWrite = 1'b1; wdSrc  = 1'b1; LUI_INSTR = 1'b1; end
            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUB; BEQ_INSTR = 1'b1; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin branch = 1'b1; aluControl = `ALU_SUB; BNE_INSTR = 1'b1; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_JAL  } : begin wdSrc = 2'b10; jal = 1'b1; regWrite = 1'b1; aluControl = `ALU_ADD; JAL_INSTR = 1'b1; end
        endcase
    end

endmodule
