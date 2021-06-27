module vcordic_rcordic_chain
   (input wire[31:0]  t_data,   // input
    input wire        t_valid,
    output reg        t_ready,

    output reg [31:0] i_data,   // output
    output reg        i_valid,
    input wire        i_ready,


    input wire        clk, rstf
    );

    logic [31:0]      vcordic_idata;
    logic             vcordic_ivalid;
    logic             vcordic_iready;


  assign vcordic_idata[15:0] = 16'h0;

/* verilator lint_off PINMISSING */
    vcordic vcordic_0
     (.t_x(t_data[15:0]),
      .t_y(t_data[31:16]),
      .t_valid(t_valid),
      .t_ready(t_ready),
      // .i_mag(vcordic_idata[31:16]), // unused
      .i_angle(vcordic_idata[31:16]),
      .i_valid(vcordic_ivalid),
      .i_ready(vcordic_iready),
      .clk(clk),
      .rstf(rstf)
      );
/* verilator lint_on PINMISSING */

    nco rcordic_0
      (.t_angle_dat(vcordic_idata),
       .t_angle_req(vcordic_ivalid),
       .t_angle_ack(vcordic_iready),
       .i_nco_dat(i_data),
       .i_nco_req(i_valid),
       .i_nco_ack(i_ready),
       .clk(clk),
       .reset_n(rstf)
       );

endmodule