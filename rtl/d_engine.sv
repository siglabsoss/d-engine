module d_engine
  #(
    parameter SCALAR_MEM_0 = "scalar0.mif",
    parameter SCALAR_MEM_1 = "scalar1.mif",
    parameter SCALAR_MEM_2 = "scalar2.mif",
    parameter SCALAR_MEM_3 = "scalar3.mif",
    parameter NO_RISCV = 0
    ) 
   (input wire clk,
    /* verilator lint_off SYNCASYNCNET */
    input wire         srst,
    /* verilator lint_on SYNCASYNCNET */
    input wire         debugReset,
    //t0_stream
    input wire [31:0]  t0_data,
    input wire         t0_last,
    input wire         t0_valid,
    output wire        t0_ready,
    //temporary
    output wire [31:0] i0_data,
    output wire        i0_last,
    output wire        i0_valid,
    input wire         i0_ready,

    inout wire [21:0]  gpio,

    //control and status
    input wire [31:0]  status,
    output wire [31:0] control,

    input              i_ringbus_0,
    output             o_ringbus_0,

    input wire [1:0]         func0,
    input wire [1:0]         func1,
    
    //jtag
    input              jtag_tms,
    input              jtag_tdi,
    output             jtag_tdo,
    input              jtag_tck
   
    );

   
   localparam AWIDTH=13;
   localparam DEPTH=8192;
   

   localparam CROSSBAR_INPUTS=3;
   localparam IARB_ADDR_WIDTH=16;

   

   wire                      iBus_cmd_valid;
   wire                      iBus_cmd_ready;
   wire [31:0]               iBus_cmd_payload_pc;
   wire                      iBus_rsp_ready;
   wire                      iBus_rsp_error;
   wire [31:0]               iBus_rsp_inst;

   assign iBus_rsp_error = 1'b0;

   wire                      dBus_cmd_valid;
   wire                      dBus_cmd_ready;
   wire                      dBus_cmd_payload_wr;
   wire [31:0]               dBus_cmd_payload_address;
   wire [31:0]               dBus_cmd_payload_data;
   wire [1:0]                dBus_cmd_payload_size;
   wire                      dBus_rsp_ready;
   wire                      dBus_rsp_error;
   wire [31:0]               dBus_rsp_data;




   reg                       debug_bus_cmd_valid;
   reg                       debug_bus_cmd_ready;
   reg                       debug_bus_cmd_payload_wr;
   reg [7:0]                 debug_bus_cmd_payload_address;
   reg [31:0]                debug_bus_cmd_payload_data;
   reg [31:0]                debug_bus_rsp_data;
   reg                       debug_resetOut;



   wire                      ringbus_0_interrupt_clear;
   wire [31:0]               ringbus_0_write_data;
   wire [31:0]               ringbus_0_write_addr;
   wire                      ringbus_0_write_done;
   wire                      ringbus_0_write_en;
   wire [31:0]               ringbus_0_read_data;
   wire                      ringbus_0_read_valid;
   wire                      ringbus_0_read_ready;
   wire                      ringbus_0_interrupt;
   wire                      ringbus_0_rd_of;
   wire                      ringbus_0_write_ready;


   wire [21:0]               gpio_read;
   wire [21:0]               gpio_write;
   wire [21:0]               gpio_writeEnable;


   wire [17:0]               i0_scalar_vmem_addr;
   wire [31:0]               i0_scalar_vmem_data;
   wire                      i0_scalar_vmem_we;
   wire                      i0_scalar_vmem_valid;
   wire                      i0_scalar_vmem_ready;
   wire [31:0]               t0_scalar_vmem_data;
   wire                      t0_scalar_vmem_valid;
   
   
   wire [3:0]                dBus_cmd_payload_mask;
   wire [9:0]                gpio_discard;

   wire                      dengine_reset;
   wire [31:0]               dengine_func0MinThreshold;
   wire [31:0]               dengine_func0MaxThreshold;
   wire [31:0]               dengine_func1MinThreshold;
   wire [31:0]               dengine_func1MaxThreshold;

// `ifdef RISCV
   
/* verilator lint_off PINMISSING */
   generate if (!NO_RISCV) begin: VexRiscv
      XbbRiscv VexRiscv 
        (
         .io_asyncReset(srst),
         .io_mainClk(clk),
         
         .iBus_cmd_valid(iBus_cmd_valid),
         .iBus_cmd_ready(iBus_cmd_ready),
         .iBus_cmd_payload_pc(iBus_cmd_payload_pc),
         .iBus_rsp_ready(iBus_rsp_ready),
         .iBus_rsp_error(iBus_rsp_error),
         .iBus_rsp_inst(iBus_rsp_inst),
`ifdef EXTRA_RINGBUS      
         .io_externalInterrupt({6'b0}),
`else
         .io_externalInterrupt({6'b0}),
`endif
         .jtag_tms(jtag_tms),
         .jtag_tdi(jtag_tdi),
         .jtag_tdo(jtag_tdo),
         .jtag_tck(jtag_tck),

         //uart
         //.io_uart_txd(),
         //.io_uart_rxd(),
         
         .scalarMemBus_cmd_valid(dBus_cmd_valid),
         .scalarMemBus_cmd_ready(dBus_cmd_ready),
         .scalarMemBus_cmd_payload_wr(dBus_cmd_payload_wr),
         .scalarMemBus_cmd_payload_address(dBus_cmd_payload_address),
         .scalarMemBus_cmd_payload_data(dBus_cmd_payload_data),
         .scalarMemBus_cmd_payload_mask(dBus_cmd_payload_mask),
         .scalarMemBus_rsp_valid(dBus_rsp_ready),
         .scalarMemBus_rsp_payload_data(dBus_rsp_data),
         
         //.io_vmemBus_cmd_valid(),
         .io_vmemBus_cmd_ready(1'b1),
         //.io_vmemBus_cmd_payload_wr(),
         //.io_vmemBus_cmd_payload_address(),
         //.io_vmemBus_cmd_payload_data(),
         //.io_vmemBus_cmd_payload_mask(),
         .io_vmemBus_rsp_valid(1'b1),
         .io_vmemBus_rsp_payload_data(32'hDEADBEEF),
         
         //.xbaseband_cmd_valid(),
         .xbaseband_cmd_ready(1'b1),
         //.xbaseband_cmd_payload_instruction(),
         //.xbaseband_cmd_payload_rs1(),
         
         //.dma_0_dmaReset(),
         .dma_0_status(32'h0),
         //.dma_0_interrupt_clear(),
         //.dma_0_config_valid(),
         .dma_0_config_ready(1'b1),
         //.dma_0_config_payload_startAddr(),
         //.dma_0_config_payload_length(),
         //.dma_0_config_payload_timerInit(),
         //.dma_0_config_payload_reverse(),
         //.dma_0_config_payload_last_or_run_till_last(),
         
         //.dma_1_dmaReset(),
         .dma_1_status(32'h0),
         //.dma_1_interrupt_clear(),
         //.dma_1_config_valid(),
         .dma_1_config_ready(1'b1),
         //.dma_1_config_payload_startAddr(),
         //.dma_1_config_payload_length(),
         //.dma_1_config_payload_timerInit(),
         //.dma_1_config_payload_slicer(),
         //.dma_1_config_payload_reverse(),
         //.dma_1_config_payload_last_or_run_till_last(),
         //.dma_1_config_payload_demapper_constellation(),
         //.dma_1_config_payload_demapper_two_over_sigma_sq(),
         
         //.dma_2_dmaReset(),
         .dma_2_status(32'h0),
         //.dma_2_interrupt_clear(),
         //.dma_2_config_valid(),
         .dma_2_config_ready(1'b1),
         //.dma_2_config_payload_startAddr(),
         //.dma_2_config_payload_length(),
         //.dma_2_config_payload_timerInit(),
         //.dma_2_config_payload_reverse(),
         //.dma_2_config_payload_last_or_run_till_last(),
         
         //.io_timerStatus_gtimer(timerCsr_gtimer),
         
         .ringbus_0_interrupt_clear(ringbus_0_interrupt_clear),
         .ringbus_0_config_valid(ringbus_0_write_en),
         .ringbus_0_config_ready(ringbus_0_write_ready),
         .ringbus_0_config_payload_write_data(ringbus_0_write_data),
         .ringbus_0_config_payload_write_addr(ringbus_0_write_addr),
         .ringbus_0_read_payload_read_data(ringbus_0_read_data),
         .ringbus_0_read_valid(ringbus_0_read_valid),
         .ringbus_0_read_ready(ringbus_0_read_ready),
         .ringbus_0_write_done(ringbus_0_write_done),

         //.ringbus_1_interrupt_clear(),
         //.ringbus_1_config_valid(),
         .ringbus_1_config_ready(1'b1),
         //.ringbus_1_config_payload_write_data(),
         //.ringbus_1_config_payload_write_addr(),
         .ringbus_1_read_payload_read_data(32'h0),
         .ringbus_1_read_valid(1'b0),
         //.ringbus_1_read_ready(),
         .ringbus_1_write_done(1'b0),

         //.nco_ncoReset(),
         //.nco_busy(),
         //.nco_config_valid(),
         .nco_config_ready(1'b1),
         //.nco_config_payload_startAngle(),
         //.nco_config_payload_delta(),
         //.nco_config_payload_length(),

         //.mapmov_mover_active(),
         //.mapmov_trim_start(),
         //.mapmov_trim_end(),
         //.mapmov_pilot_ram_addr(),
         //.mapmov_pilot_ram_wdata(),
         //.mapmov_pilot_ram_we(),
         //.mapmov_reset(),
         //.mapmov_one_value(),
         //.mapmov_zero_value(),

         //.satDetect_satDetect(),
         .control_control(control),
         .status_status(status),
         .dengine_reset(dengine_reset),
         .dengine_func0MinThreshold(dengine_func0MinThreshold),
         .dengine_func0MaxThreshold(dengine_func0MaxThreshold),
         .dengine_func1MinThreshold(dengine_func1MinThreshold),
         .dengine_func1MaxThreshold(dengine_func1MaxThreshold),
         //.slicer_value(),
         .io_gpio({gpio_discard,gpio})
         );
   end else begin
      assign ringbus_0_interrupt_clear=1'b1;
   end endgenerate // else: !if(!NO_RISCV)
/* verilator lint_on PINMISSING */
   
   scalar_memory
     #(.AWIDTH     (AWIDTH),
       .DEPTH      (DEPTH),
       .SCALAR_MEM_0(SCALAR_MEM_0),
       .SCALAR_MEM_1 (SCALAR_MEM_1),
       .SCALAR_MEM_2 (SCALAR_MEM_2),
       .SCALAR_MEM_3 (SCALAR_MEM_3)

       ) 
   mem (
        .clk        (clk),
        .srst       (srst),
        .t0_valid   (iBus_cmd_valid),
        .t0_ready   (iBus_cmd_ready),
        .t0_we      (1'b0),
        .t0_mask    (4'h0),
        .t0_addr    (iBus_cmd_payload_pc),
        .t0_data    (32'b0),

        .i0_valid   (iBus_rsp_ready),
        .i0_ready   (1'b1),
        .i0_data    (iBus_rsp_inst),
      
        .t1_valid   (dBus_cmd_valid),
        .t1_ready   (dBus_cmd_ready),
        .t1_we      (dBus_cmd_payload_wr),
        .t1_mask    (dBus_cmd_payload_mask),
        .t1_addr    (dBus_cmd_payload_address),
        .t1_data    (dBus_cmd_payload_data),
      
        .i1_valid   (dBus_rsp_ready),
        .i1_ready   (1'b1),
        .i1_data    (dBus_rsp_data)
        );

// `endif

   wire                  ringbus_0_buf_empty;

   assign ringbus_0_interrupt = ~ringbus_0_buf_empty;
   
   ring_bus ring_bus_inst
     (.i_sysclk(clk),         // 125 MHz
      .i_srst(srst),

      .i_wr_data(ringbus_0_write_data),
      .i_wr_addr(ringbus_0_write_addr),
      .o_done_wr(ringbus_0_write_done),
      .i_start_wr(ringbus_0_write_en),
      .o_write_ready(ringbus_0_write_ready),
      
      .o_rd_data(ringbus_0_read_data),
      .o_rd_valid(ringbus_0_read_valid),
      .i_rd_ready(ringbus_0_read_ready),
      .o_rd_buf_empty(ringbus_0_buf_empty),
      .o_rd_of(ringbus_0_rd_of),
      .i_clear_flags(ringbus_0_interrupt_clear), //clears all flags

      .o_serial_bus(o_ringbus_0),
      .i_serial_bus(i_ringbus_0)
      );

   /* verilator lint_off PINMISSING */
   d_process d_process_0
     (.t_data(t0_data),
      .t_last(t0_last),
      .t_valid(t0_valid),
      .t_ready(t0_ready),

      .i_data(i0_data),
      .i_last(i0_last),
      .i_valid(i0_valid),
      .i_ready(i0_ready),

      .func0(func0),
      .func1(func1),
      .func0MinThreshold(dengine_func0MinThreshold),
      .func0MaxThreshold(dengine_func0MaxThreshold),
      .func1MinThreshold(dengine_func1MinThreshold),
      .func1MaxThreshold(dengine_func1MaxThreshold),
      //.sat_detect(),

      .clk(clk),
      .rstf(~srst)
      );
   /* verilator lint_on PINMISSING */

endmodule
