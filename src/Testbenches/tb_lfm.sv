module tb_lfm;

    logic        clk;
    logic        rst;

    wire  [31:0] imAddr;   // instruction memory address
    wire  [31:0] imData;   // instruction memory data

    logic [ 4:0] regAddr;  // debug access reg address
    wire  [31:0] regData;  // debug access reg data

    //DEBUG_PORTS
    wire [13:0] decode_instr;
    wire [31:0] rd_0_debug;
    wire [31:0] rd_1_debug;
    wire [31:0] wd_debug;
    wire        regWrite_debug;
    wire [2:0]  aluControl_debug;

    risc_v_top cpu
    (
        .clk     ( clk     ),
        .rst     ( rst     ),

        .rd_0_debug(rd_0_debug),
        .rd_1_debug(rd_1_debug),
        .wd_debug(wd_debug),
        .regWrite_debug(regWrite_debug),
        .aluControl_debug(aluControl_debug),

        .imAddr_debug  ( imAddr  ),
        .ImData_debug  ( imData  ),

        .regAddr ( regAddr ),
        .regData ( regData ),

        .decode_instr(decode_instr)

    );

    //------------------------------------------------------------------------

    initial begin
        clk = 1'b0;

        forever
          #5 clk = ~ clk;
    end

    //------------------------------------------------------------------------

    initial begin
        rst <= 1'bx;
        repeat (2) @ (posedge clk);
        rst <= 1'b1;
        repeat (2) @ (posedge clk);
        rst <= 1'b0;
    end

    //------------------------------------------------------------------------

    initial begin
        `ifdef __ICARUS__
            $dumpvars;
        `endif

        regAddr <= 5'd10;  // a0 register used for I/O

        @ (negedge rst);

        repeat (4000)
        begin
            @ (posedge clk);

            if ( regData == 32'h1c8cfc00 )  // Factorial
            begin
                 $display ("%s PASS", `__FILE__);
                 $finish;
            end
        end

        $display ("%s FAIL: none of expected register values occured",
            `__FILE__);

        $finish;
    end

    //------------------------------------------------------------------------

    int unsigned cycle = 0;
    bit wasRst = 1'b0;

    logic [31:0] prevImAddr;
    logic [31:0] prevRegData;

    always_ff @ (posedge clk)
    begin
        $write ("cycle %5d\n", cycle++);

        if (rst)
        begin
            $write ("rst - signal assert! \n");
            wasRst <= 1'b1;
        end
        else
        begin
          case(decode_instr)

            14'd1: begin
              $display("Detect ADD instruction!\n");
              $display("Instruction value: rs1 - %5d, rs2 - %5d, rd - %5d\n", imData[19:15],  imData[24:20],  imData[11:7]);

            end

            14'd2: begin
              $display("Detect OR instruction! - \n");
            end

            14'd3: begin
              $display("Detect SLR instruction! - \n");
            end

            14'd4: begin
              $display("Detect SLTU instruction! - \n");
            end

            14'd5: begin
              $display("Detect SUB instruction! - \n");
            end

            14'd6: begin
              $display("Detect MUL instruction! - \n");
            end

            14'd7: begin
              $display("Detect LW instruction! - \n");
            end

            14'd8: begin
              $display("Detect SW instruction! - \n");
            end

            14'd9: begin
              $display("Detect ADDI instruction!");
              $display("Instruction value: constant - %d, rs1 - %d, rd - %d", imData[31:20],  imData[19:15],  imData[11:7]);
              $display();


            end

            14'd10: begin
              $display("Detect LUI instruction! - \n");
            end

            14'd11: begin
              $display("Detect AUIPC instruction! - \n");
            end

            14'd12: begin
              $display("Detect BEQ instruction! - \n");
            end

            14'd13: begin
              $display("Detect BNE instruction! - \n");
            end

            14'd14: begin
              $display("Detect JAL instruction! - \n");
            end
          endcase
        end

        if (wasRst & ~rst & $isunknown (imData))
        begin
            $display ("%s FAIL: fetched instruction at address %x contains Xs: %x",
                `__FILE__, imAddr, imData);

            //$finish;
        end



        prevImAddr  <= imAddr;
        prevRegData <= regData;

        $display;
    end

endmodule
