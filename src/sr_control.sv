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
    output logic [ 1:0] immSrc
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

        casez ({ cmdF7, cmdF3, cmdOp })
            { `RVF7_ADD,  `RVF3_ADD,  `RVOP_ADD  } : begin regWrite = 1'b1; aluControl = `ALU_ADD;  end
            { `RVF7_OR,   `RVF3_OR,   `RVOP_OR   } : begin regWrite = 1'b1; aluControl = `ALU_OR;   end
            { `RVF7_SRL,  `RVF3_SRL,  `RVOP_SRL  } : begin regWrite = 1'b1; aluControl = `ALU_SRL;  end
            { `RVF7_SLTU, `RVF3_SLTU, `RVOP_SLTU } : begin regWrite = 1'b1; aluControl = `ALU_SLTU; end
            { `RVF7_SUB,  `RVF3_SUB,  `RVOP_SUB  } : begin regWrite = 1'b1; aluControl = `ALU_SUB;  end
            { `RVF7_MUL,  `RVF3_MUL,  `RVOP_MUL  } : begin regWrite = 1'b1; aluControl = `ALU_MUL;  end
            { `RVF7_ANY,  `RVF3_LW,   `RVOP_LW   } : begin regWrite = 1'b1; ResultSrc = 1'b1; aluSrc = 1'b1; immSrc = '0; aluControl = `ALU_ADD;  end
            { `RVF7_ANY,  `RVF3_SW,   `RVOP_SW   } : begin MemWrite = 1'b1; aluControl = `ALU_ADD; aluSrc = 1'b1; immSrc = 2'b01; end
            { `RVF7_ANY,  `RVF3_ADDI, `RVOP_ADDI } : begin regWrite = 1'b1; aluSrc = 1'b1; aluControl = `ALU_ADD; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_LUI  } : begin regWrite = 1'b1; wdSrc  = 1'b1; end
            { `RVF7_ANY,  `RVF3_BEQ,  `RVOP_BEQ  } : begin branch = 1'b1; condZero = 1'b1; aluControl = `ALU_SUB; end
            { `RVF7_ANY,  `RVF3_BNE,  `RVOP_BNE  } : begin branch = 1'b1; aluControl = `ALU_SUB; end
            { `RVF7_ANY,  `RVF3_ANY,  `RVOP_JAL  } : begin wdSrc = 2'b10; jal = 1'b1; regWrite = 1'b1; aluControl = `ALU_ADD; end

        endcase
    end

endmodule
