module tb;

    logic        clk;
    logic        rst;

    wire  [31:0] imAddr;   // instruction memory address
    wire  [31:0] imData;   // instruction memory data

    logic [ 4:0] regAddr;  // debug access reg address
    wire  [31:0] regData;  // debug access reg data

    //DEBUG_PORTS
    wire ADD_INSTR;
    wire OR_INSTR;
    wire SRL_INSTR;
    wire SLTU_INSTR;
    wire SUB_INSTR;
    wire MUL_INSTR;
    wire LW_INSTR;
    wire SW_INSTR;
    wire ADDI_INSTR;
    wire LUI_INSTR;
    wire BEQ_INSTR;
    wire BNE_INSTR;
    wire JAL_INSTR;    

    sr_cpu cpu
    (
        .clk     ( clk     ),
        .rst     ( rst     ),

        .imAddr  ( imAddr  ),
        .imData  ( imData  ),

        .regAddr ( regAddr ),
        .regData ( regData ),

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

    instruction_rom # (.SIZE (1024)) rom
    (
        .a       ( imAddr  ),
        .rd      ( imData  )
    );

    //------------------------------------------------------------------------

    initial
    begin
        clk = 1'b0;

        forever
          #5 clk = ~ clk;
    end

    //------------------------------------------------------------------------

    initial
    begin
        rst <= 1'bx;
        repeat (2) @ (posedge clk);
        rst <= 1'b1;
        repeat (2) @ (posedge clk);
        rst <= 1'b0;
    end

    //------------------------------------------------------------------------

    initial
    begin
        `ifdef __ICARUS__
            // Uncomment the following `define
            // to generate a VCD file and analyze it using GTKwave

            $dumpvars;
        `endif

        regAddr <= 5'd10;  // a0 register used for I/O

        @ (negedge rst);

        repeat (4000)
        begin
            @ (posedge clk);

            if (  regData == 32'h00213d05 )   // Fibonacci
            //     | regData == 32'h1c8cfc00 )  // Factorial
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

    always @ (posedge clk)
    begin
        $write ("cycle %5d", cycle ++);

        if (rst)
        begin
            $write (" rst");
            wasRst <= 1'b1;
        end
        else
        begin
            $write ("    ");
        end

        if (imAddr !== prevImAddr)
            $write (" %h", imAddr);
        else
            $write ("Error, pc_counter is stuck!");

        if (wasRst & ~ rst & $isunknown (imData))
        begin
            $display ("%s FAIL: fetched instruction at address %x contains Xs: %x",
                `__FILE__, imAddr, imData);

            //$finish;
        end

        if (regData !== prevRegData)
            $write (" %h", regData);
        else
            $write ("         ");

        prevImAddr  <= imAddr;
        prevRegData <= regData;

        $display;
    end

endmodule
