module angle_to_amp 
  (
  input [31:0] lfm_coef,
  input [31:0] time_limit_lfm,
  input data_clk, 
  input [15:0] freq_control,
  input enable,
  input reset_fpga,
  output [15:0] I,
  output [15:0] Q
  );
  
  //wire declarations
  wire [14:0] acc_out;
  wire [15:0] lut_data_sin;
  wire [15:0] lut_data_cos;
  wire [14:0] adress_sin;
  wire [14:0] adress_cos;
  
  //reg declarations
  logic [15:0] acc_phase_sin;
  logic [15:0] acc_phase_cos;
  logic [15:0] out_data_sin;
  logic [15:0] out_data_cos;
  logic overflow_sin;
  logic overflow_cos;
  logic [3:0] State_sin;
  logic [3:0] State_cos;
  logic [15:0] freq_control_lfm;
 
  
  //parameter declarations
  localparam [3:0] INIT_STATE_SIN  = 0;
  localparam [3:0] START_FORM_SIN   = 1;
  localparam [3:0] PLUS_SINE_FORM   = 2;
  localparam [3:0] MINUS_SINE_FORM  = 3;
  localparam [3:0] INIT_STATE_COS   = 0;
  localparam [3:0] START_FORM_COS   = 1;
  localparam [3:0] PLUS_COS_FORM    = 2;
  localparam [3:0] MINUS_COS_FORM   = 3;
  localparam [15:0] cos_start       = 16384;
  localparam [15:0] sin_start       = 0;

  
  lut lut
    (
    .addr_a(adress_sin),
    .addr_b(adress_cos),
    .q_a(lut_data_sin),
    .q_b(lut_data_cos),
    .clk(data_clk)
  );
  
    assign I = out_data_sin;
    assign Q = out_data_cos;
    assign adress_sin = acc_phase_sin [14:0];
    assign adress_cos = acc_phase_cos [14:0];
    assign freq_control_lfm = freq_control + lfm_coef;
   
  always_comb begin
    if (acc_phase_sin < 32768) out_data_sin = lut_data_sin;
    else out_data_sin = ~lut_data_sin + 1'b1;
    if (acc_phase_cos < 32768) out_data_cos = lut_data_cos;
    else out_data_cos = ~lut_data_cos + 1'b1;
  end

   

  always_ff @(posedge data_clk) begin
    if (reset_fpga) begin
      acc_phase_sin <= sin_start;
      State_sin <= INIT_STATE_SIN;
    end else begin
      case(State_sin)
      //-----------------------------
      INIT_STATE_SIN:
        begin
        acc_phase_sin <= sin_start;
        overflow_sin <= '0;
        if (freq_control_lfm != '0) State_sin <= START_FORM_SIN;
        end
      //-----------------------------
      START_FORM_SIN:
        begin
          acc_phase_sin <= sin_start;
          State_sin <= PLUS_SINE_FORM;
        end
      //-----------------------------
      PLUS_SINE_FORM:
        if ((acc_phase_sin < 32768) && (overflow_sin == 0)) begin
          acc_phase_sin <= acc_phase_sin + freq_control_lfm;
        end else begin
        if (acc_phase_sin >= 32768) begin
          acc_phase_sin <= acc_phase_sin + freq_control_lfm;
          overflow_sin <= 1'b1;
          State_sin <= MINUS_SINE_FORM;
        end
        end
      //-----------------------------
      MINUS_SINE_FORM:
        if ((acc_phase_sin > 32768) && (overflow_sin == 1'b1))  begin
        acc_phase_sin <= acc_phase_sin + freq_control_lfm;
        end else begin
        if (acc_phase_sin < 32768) begin
          acc_phase_sin <= acc_phase_sin + freq_control_lfm;
          overflow_sin <= '0;
          State_sin <= PLUS_SINE_FORM;
        end
        end
          
      default:
        begin
          State_sin <= INIT_STATE_SIN;
        end
      endcase
      end
      end
      

     always_ff @(posedge data_clk) begin
    if  (reset_fpga) begin      
      acc_phase_cos <= cos_start;
      State_cos <= INIT_STATE_COS;     
    end else begin
      case(State_cos)
      //-----------------------------
      INIT_STATE_COS:
        begin
        acc_phase_cos <= cos_start;
        overflow_cos <= 0;
        if (freq_control_lfm != '0) State_cos <= START_FORM_COS;
        end
      //-----------------------------
      START_FORM_COS:
        begin
          acc_phase_cos <= acc_phase_cos;
          State_cos <= PLUS_COS_FORM;
        end
      //-----------------------------
      PLUS_COS_FORM:
        if ((acc_phase_cos < 32768) && (overflow_cos == 0)) begin
          acc_phase_cos <= acc_phase_cos + freq_control_lfm;
        end else begin
        if (acc_phase_cos >= 32768) begin
          acc_phase_cos <= acc_phase_cos + freq_control_lfm;
          overflow_cos <= 1;
          State_cos <= MINUS_COS_FORM;
        end
        end
      MINUS_COS_FORM:
        if ((acc_phase_cos > 32768) && (overflow_cos == 1))  begin
        acc_phase_cos <= acc_phase_cos + freq_control_lfm;
        end else begin
        if (acc_phase_cos < 32768) begin
          acc_phase_cos <= acc_phase_cos + freq_control_lfm;
          overflow_cos <= 0;
          State_cos <= PLUS_COS_FORM;
        end
        end
          
      default:
        begin
          State_cos <= INIT_STATE_COS;
        end
      endcase
      end
      end
    
endmodule
