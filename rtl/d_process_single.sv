module d_process_single
  (input wire[31:0]  t_data,
   input wire        t_last,
   input wire        t_valid,
   output reg        t_ready,

   output reg [31:0] i_data,
   output reg        i_last,
   output reg        i_valid,
   input wire        i_ready,

   input wire        dengine_reset,
   
   // input wire [1:0]  func0,
   // input wire [1:0]  func1,

   input wire [31:0] func0MinThreshold,
   input wire [31:0] func0MaxThreshold,
   // input wire [31:0] func1MinThreshold,
   // input wire [31:0] func1MaxThreshold,

   input wire [15:0] sat_detect,

   input wire        clk, rstf
  
   );

   logic             func0_fifo_wvalid;
   logic [31:0]      func0_fifo_wdata;
   logic             func0_fifo_rready;
   logic [31:0]      func0_fifo_rdata;
   logic             func0_fifo_rvalid;
/* verilator lint_off PINMISSING */
   fwft_sc_fifo 
     #(.DEPTH(1024),
       .WIDTH(32)
       )
   func0_fifo
     (.clk(clk),
      .rst(~rstf),
      .wren(func0_fifo_wvalid),
      .wdata(func0_fifo_wdata),
      .rden(func0_fifo_rready),
      .rdata(func0_fifo_rdata),
      .rdata_vld(func0_fifo_rvalid)
      );
   /* verilator lint_on PINMISSING */
   
   // logic             func1_fifo_wvalid;
   // logic [31:0]      func1_fifo_wdata;
   // logic             func1_fifo_rready;
   // logic [31:0]      func1_fifo_rdata;
   // logic             func1_fifo_rvalid;
   /* verilator lint_off PINMISSING */
   // fwft_sc_fifo 
   //   #(.DEPTH(1024),
   //     .WIDTH(32)
   //     )
   // func1_fifo
   //   (.clk(clk),
   //    .rst(~rstf),
   //    .wren(func1_fifo_wvalid),
   //    .wdata(func1_fifo_wdata),
   //    .rden(func1_fifo_rready),
   //    .rdata(func1_fifo_rdata),
   //    .rdata_vld(func1_fifo_rvalid)
   //    );
   /* verilator lint_on PINMISSING */


   localparam logic [1:0] VCORDIC = 2'd0;
   localparam logic [1:0] RCORDIC = 2'd1;
   localparam logic [1:0] RECIPROCAL = 2'd2;
   localparam logic [1:0] VCORDIC_RCORDIC_CHAIN = 2'd0;  // overloaded, do not use others

   logic [1:0] func0;

   assign func0 = VCORDIC_RCORDIC_CHAIN;


   enum                   logic [2:0] { RUN_TILL_LAST,
                                        CAPTURE_DATA,
                                        CAPTURE_TRUNK,
                                        SEND_FUNC0,
                                        SEND_FUNC1,
                                        SEND_TRUNK
                                        } q_state, n_state;

   logic [15:0]           q_cnt, n_cnt;
   logic [31:0]           q_func0_sat_cnt, n_func0_sat_cnt;
   logic [31:0]           q_func1_sat_cnt, n_func1_sat_cnt;
   
   logic [31:0]           q_trunk[16], n_trunk[16];
   
   logic [31:0]           rcordic_tdata, rcordic_idata;
   logic                  rcordic_tvalid, rcordic_ivalid;
   logic                  rcordic_tready, rcordic_iready;

   logic [31:0]           vcordic_tdata, vcordic_idata;
   logic                  vcordic_tvalid, vcordic_ivalid;
   logic                  vcordic_tready, vcordic_iready;

   logic [31:0]           reciprocal_tdata, reciprocal_idata;
   logic                  reciprocal_tvalid, reciprocal_ivalid;
   logic                  reciprocal_tready, reciprocal_iready;


   assign vcordic_tdata = (func0 == VCORDIC) ? func0_fifo_rdata : 0;
   
   assign vcordic_tvalid = (func0 == VCORDIC) ? func0_fifo_rvalid : 0;

   // assign rcordic_tdata = (func0 == RCORDIC) ? func0_fifo_rdata : 0;
   
   // assign rcordic_tvalid = (func0 == RCORDIC) ? func0_fifo_rvalid : 0;

   // assign reciprocal_tdata = (func0 == RECIPROCAL) ? func0_fifo_rdata : 0;
   
   // assign reciprocal_tvalid = (func0 == RECIPROCAL) ? func0_fifo_rvalid : 0;

   assign func0_fifo_rready = (func0 == VCORDIC) ? vcordic_tready: 0;
                              // (func0 == RCORDIC) ? rcordic_tready:
                              // (func0 == RECIPROCAL) ? reciprocal_tready: 0;


   vcordic_rcordic_chain vr_chain_0
   (
     .t_data  (vcordic_tdata),
     .t_valid (vcordic_tvalid),
     .t_ready (vcordic_tready),

     .i_data  (vcordic_idata),
     .i_valid (vcordic_ivalid),
     .i_ready (vcordic_iready),

     .clk(clk),
     .rstf(rstf)
    );

   // vcordic vcordic_0
   //   (.t_x(vcordic_tdata[15:0]),
   //    .t_y(vcordic_tdata[31:16]),
   //    .t_valid(vcordic_tvalid),
   //    .t_ready(vcordic_tready),
   //    .i_mag(vcordic_idata[31:16]),
   //    .i_angle(vcordic_idata[15:0]),
   //    .i_valid(vcordic_ivalid),
   //    .i_ready(vcordic_iready),
   //    .clk(clk),
   //    .rstf(rstf)
   //    );
   
   // nco rcordic_0
   //   (.t_angle_dat(rcordic_tdata),
   //    .t_angle_req(rcordic_tvalid),
   //    .t_angle_ack(rcordic_tready),
   //    .i_nco_dat(rcordic_idata),
   //    .i_nco_req(rcordic_ivalid),
   //    .i_nco_ack(rcordic_iready),
   //    .clk(clk),
   //    .reset_n(rstf)
   //    );

   // reciprocal reciprocal_0
   //   (.t_0_dat(reciprocal_tdata),
   //    .t_0_req(reciprocal_tvalid),
   //    .t_0_ack(reciprocal_tready),
   //    .i_16_dat(reciprocal_idata),
   //    .i_16_req(reciprocal_ivalid),
   //    .i_16_ack(reciprocal_iready),
   //    .clk(clk),
   //    .reset_n(rstf)
   //    );
   
   
   assign func0_fifo_wdata = t_data;
   // assign func1_fifo_wdata = t_data;

   assign func0_fifo_wvalid = (q_state == CAPTURE_DATA) ? t_valid&t_ready:0;
   // assign func1_fifo_wvalid = (q_state == CAPTURE_DATA) ? t_valid&t_ready:0;
   
   
   always @(*) begin
      i_data = 0;
      i_valid = 0;
      i_last = 0;
      n_state = q_state;
      t_ready = 0;
      n_cnt = q_cnt;
      n_trunk = q_trunk;
      rcordic_iready = 0;
      vcordic_iready = 0;
      reciprocal_iready = 0;
      n_func0_sat_cnt = q_func0_sat_cnt;
      n_func1_sat_cnt = q_func1_sat_cnt;
      case(q_state)
        RUN_TILL_LAST: begin
           t_ready = 1;
           n_cnt = 0;
           if(t_last & t_valid)
             n_state = CAPTURE_DATA;
        end
        CAPTURE_DATA: begin
           t_ready = i_ready;
           i_data = t_data;
           i_valid = t_valid;

           n_func0_sat_cnt = 0;
           n_func1_sat_cnt = 0;
      
           if(t_valid&i_ready) begin
              n_cnt = q_cnt + 1;
              if(q_cnt == 1023) begin
                 n_state = CAPTURE_TRUNK;
                 n_cnt = 0;
              end
           end
        end
        CAPTURE_TRUNK: begin
           t_ready = 1;
           n_trunk[q_cnt[3:0]] = t_data;
           if(t_valid) begin
              n_cnt = q_cnt + 1;
              if(q_cnt == 15) begin
                 n_state = SEND_FUNC0;
                 n_cnt = 0;
              end
           end
        end
        SEND_FUNC0: begin
           i_data = (func0 == VCORDIC) ?  vcordic_idata :
                    (func0 == RCORDIC) ? rcordic_idata : reciprocal_idata;
           i_valid = (func0 == VCORDIC) ?  vcordic_ivalid :
                     (func0 == RCORDIC) ? rcordic_ivalid : reciprocal_ivalid;
           vcordic_iready = (func0 == VCORDIC) ? i_ready : 0;
           rcordic_iready = (func0 == RCORDIC) ? i_ready : 0;
           reciprocal_iready = (func0 == RECIPROCAL) ? i_ready : 0;
           if(i_valid & i_ready) begin
              if($signed(i_data) < $signed(func0MinThreshold) || $signed(i_data) > $signed(func0MaxThreshold))
                n_func0_sat_cnt = q_func0_sat_cnt + 1;
              
              n_cnt = q_cnt + 1;
              if(q_cnt == 1023) begin
                 n_state = SEND_TRUNK;
                 n_cnt = 0;
              end
           end
        end
        // SEND_FUNC1: begin
        //    i_data = (func1 == VCORDIC) ?  vcordic_idata :
        //             (func1 == RCORDIC) ? rcordic_idata : reciprocal_idata;
        //    i_valid = (func1 == VCORDIC) ?  vcordic_ivalid :
        //              (func1 == RCORDIC) ? rcordic_ivalid : reciprocal_ivalid;
        //    vcordic_iready = (func1 == VCORDIC) ? i_ready : 0;
        //    rcordic_iready = (func1 == RCORDIC) ? i_ready : 0;
        //    reciprocal_iready = (func1 == RECIPROCAL) ? i_ready : 0;
        //    if(i_valid & i_ready) begin
        //       if($signed(i_data) < $signed(func1MinThreshold) || $signed(i_data) > $signed(func1MaxThreshold))
        //         n_func1_sat_cnt = q_func1_sat_cnt + 1;
              
        //       n_cnt = q_cnt + 1;
        //       if(q_cnt == 1023) begin
        //          n_state = SEND_TRUNK;
        //          n_cnt = 0;
        //       end
        //    end
        // end
        SEND_TRUNK: begin
           i_valid = 1;
           i_data = q_trunk[q_cnt[3:0]];
           if(q_cnt[3:0] == 14)
             i_data = q_func0_sat_cnt;
           if(q_cnt[3:0] == 15)
             i_data = q_func1_sat_cnt;
           
           if(i_ready) begin
              n_cnt = q_cnt + 1;
              if(q_cnt == 15) begin
                 i_last = 1;
                 n_state = CAPTURE_DATA;
                 n_cnt = 0;
              end
           end
        end
        default:
          n_state = RUN_TILL_LAST;
      endcase // case (q_state)
   end
   

   always @(posedge clk or negedge rstf) begin
      if(~rstf | dengine_reset) begin
         q_state <= RUN_TILL_LAST;
         q_cnt <= 0;
         q_trunk <= '{16{0}};
         q_func0_sat_cnt <= 0;
         q_func1_sat_cnt <= 0;
      end
      else begin
         q_state <= n_state;
         q_cnt <= n_cnt;
         q_trunk <= n_trunk;
         q_func0_sat_cnt <= n_func0_sat_cnt;
         q_func1_sat_cnt <= n_func1_sat_cnt;
      end
   end
   

endmodule
