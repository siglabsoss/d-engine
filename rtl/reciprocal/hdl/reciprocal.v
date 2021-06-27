module reciprocal (
    // per node (target / initiator)
    input              clk,
    input              reset_n,
    input       [15:0] t_0_dat,
    input              t_0_req,
    output             t_0_ack,
    output      [15:0] i_16_dat,
    output             i_16_req,
    input              i_16_ack
);
wire       [4:0] dat2, dat4, dat4_nxt, dat5, dat5_nxt, dat6, dat6_nxt;
wire      [15:0] dat0, dat1, dat1_nxt, dat3, dat3_nxt, dat7, dat8, dat8_nxt, dat10, dat11, dat13, dat14, dat15, dat15_nxt, dat16, dat16_nxt;
wire      [31:0] dat9, dat9_nxt, dat12, dat12_nxt;
// per node
assign dat0 = t_0_dat; // node:0 is target port
assign dat1_nxt = dat0; // node:1 operator =
// node:2 macro lzc

//node:2 leading zeros counter

wire [15:0] pad_signal2;
assign pad_signal2 = dat1; //|16'd1023;

wire[15:0] stage2_0;
wire[7:0] stage2_1;
wire[3:0] stage2_2;
wire[1:0] stage2_3;

assign stage2_0 = pad_signal2;
assign stage2_1 = {stage2_0[14] | stage2_0[15],stage2_0[12] | stage2_0[13],stage2_0[10] | stage2_0[11],stage2_0[8] | stage2_0[9],stage2_0[6] | stage2_0[7],stage2_0[4] | stage2_0[5],stage2_0[2] | stage2_0[3],stage2_0[0] | stage2_0[1]};
assign stage2_2 = {stage2_1[6] | stage2_1[7],stage2_1[4] | stage2_1[5],stage2_1[2] | stage2_1[3],stage2_1[0] | stage2_1[1]};
assign stage2_3 = {stage2_2[2] | stage2_2[3],stage2_2[0] | stage2_2[1]};

wire[4:0] lzc2;

assign lzc2[0] = ~((stage2_0[15]) | (stage2_0[13] & ~stage2_0[14]) | (stage2_0[11] & ~stage2_0[14] & ~stage2_0[12]) | (stage2_0[9] & ~stage2_0[14] & ~stage2_0[12] & ~stage2_0[10]) | (stage2_0[7] & ~stage2_0[14] & ~stage2_0[12] & ~stage2_0[10] & ~stage2_0[8]) | (stage2_0[5] & ~stage2_0[14] & ~stage2_0[12] & ~stage2_0[10] & ~stage2_0[8] & ~stage2_0[6]) | (stage2_0[3] & ~stage2_0[14] & ~stage2_0[12] & ~stage2_0[10] & ~stage2_0[8] & ~stage2_0[6] & ~stage2_0[4]) | (stage2_0[1] & ~stage2_0[14] & ~stage2_0[12] & ~stage2_0[10] & ~stage2_0[8] & ~stage2_0[6] & ~stage2_0[4] & ~stage2_0[2]));
assign lzc2[1] = ~((stage2_1[7]) | (stage2_1[5] & ~stage2_1[6]) | (stage2_1[3] & ~stage2_1[6] & ~stage2_1[4]) | (stage2_1[1] & ~stage2_1[6] & ~stage2_1[4] & ~stage2_1[2]));
assign lzc2[2] = ~((stage2_2[3]) | (stage2_2[1] & ~stage2_2[2]));
assign lzc2[3] = ~((stage2_3[1]));
assign lzc2[4] = ~(|pad_signal2);

assign dat2 = lzc2;

// node:3 macro normalize
// node:3 normalize (reciprocal)

//wire [2:0] shift3_0,shift3_1,shift3_2;
//wire [15:0] val3_0,val3_1,val3_2;

//assign val3_0   = dat1[14]?dat1>>1:dat1;
//assign shift3_0 = dat1>4?3'b1:0;

//assign val3_1   = val3_0>2?val3_0>>2:val3_0;
//assign shift3_1 = val3_0>2?shift3_0+3'b10:shift3_0;

//assign val3_2   = val3_1>1?val3_1>>1:val3_1;
//assign shift3_2 = val3_1>1?shift3_1+3'b1:shift3_1;

assign dat3_nxt = (5'd6 >= dat2) ? dat1 >> (5'd6-dat2) :
 dat1 << (dat2 - 5'd6);
assign dat4_nxt = 5'd6-dat2;

assign dat5_nxt = dat4; // node:4 operator =
assign dat6_nxt = dat5; // node:5 operator =
// node:6 macro lhsOp
assign dat7 = 16'h5dd - dat3;
assign dat8_nxt = dat7; // node:7 operator =
assign dat9_nxt = ($signed(dat3) * $signed(dat7)); // node:8 operator *
// node:9 macro bitSelect
assign dat10 = dat9[25:10]; //{"port":"i_0_dat","wire":"dat10","width":16,"highSelect":25,"lowSelect":10}
// node:10 macro lhsOp
assign dat11 = 16'h401 - dat10;
assign dat12_nxt = ($signed(dat11) * $signed(dat8)); // node:11 operator *
// node:12 macro bitSelect
assign dat13 = dat12[25:10]; //{"port":"i_0_dat","wire":"dat13","width":16,"highSelect":25,"lowSelect":10}
// node:13 macro reciprocalSatShift2
assign dat14 = |dat13[15:14] ? 16'd32767 : dat13 << 2;
// node:14 macro renorm
// node: 14 renorm

assign dat15_nxt = dat6[4] ?   dat14 << (~dat6 + 1'b1) : dat14 >> dat6;

//assign dat15_nxt = dat14[15:0] >> dat14[19:16];

// node:15 macro reciprocalSat
assign dat16_nxt = dat15[15]?  16'd32767:dat15;
assign i_16_dat = dat16; // node:16 is initiator port
// per edge


// edge:1 EB1.5
wire en1_0, en1_1, sel1;
reg [15:0] dat1_r0, dat1_r1;
always @(posedge clk) if (en1_0) dat1_r0 <= dat1_nxt;
always @(posedge clk) if (en1_1) dat1_r1 <= dat1_nxt;

assign dat1 = sel1 ? dat1_r1 : dat1_r0;



// edge:3 EB1.5
wire en3_0, en3_1, sel3;
reg [15:0] dat3_r0, dat3_r1;
always @(posedge clk) if (en3_0) dat3_r0 <= dat3_nxt;
always @(posedge clk) if (en3_1) dat3_r1 <= dat3_nxt;

assign dat3 = sel3 ? dat3_r1 : dat3_r0;

wire en4; // edge:4 EB1
reg [4:0] dat4_r;
always @(posedge clk) if (en4) dat4_r <= dat4_nxt;
assign dat4 = dat4_r;

wire en5; // edge:5 EB1
reg [4:0] dat5_r;
always @(posedge clk) if (en5) dat5_r <= dat5_nxt;
assign dat5 = dat5_r;

wire en6; // edge:6 EB1
reg [4:0] dat6_r;
always @(posedge clk) if (en6) dat6_r <= dat6_nxt;
assign dat6 = dat6_r;


wire en8; // edge:8 EB1
reg [15:0] dat8_r;
always @(posedge clk) if (en8) dat8_r <= dat8_nxt;
assign dat8 = dat8_r;

wire en9; // edge:9 EB1
reg [31:0] dat9_r;
always @(posedge clk) if (en9) dat9_r <= dat9_nxt;
assign dat9 = dat9_r;



wire en12; // edge:12 EB1
reg [31:0] dat12_r;
always @(posedge clk) if (en12) dat12_r <= dat12_nxt;
assign dat12 = dat12_r;




// edge:15 EB1.5
wire en15_0, en15_1, sel15;
reg [15:0] dat15_r0, dat15_r1;
always @(posedge clk) if (en15_0) dat15_r0 <= dat15_nxt;
always @(posedge clk) if (en15_1) dat15_r1 <= dat15_nxt;

assign dat15 = sel15 ? dat15_r1 : dat15_r0;


// edge:16 EB1.5
wire en16_0, en16_1, sel16;
reg [15:0] dat16_r0, dat16_r1;
always @(posedge clk) if (en16_0) dat16_r0 <= dat16_nxt;
always @(posedge clk) if (en16_1) dat16_r1 <= dat16_nxt;

assign dat16 = sel16 ? dat16_r1 : dat16_r0;

reciprocal_ctrl uctrl (
    .clk(clk),
    .reset_n(reset_n),
    .t_0_req(t_0_req),
    .t_0_ack(t_0_ack),
    .i_16_req(i_16_req),
    .i_16_ack(i_16_ack),
    .en1_0(en1_0),
    .en1_1(en1_1),
    .sel1(sel1),
    .en3_0(en3_0),
    .en3_1(en3_1),
    .sel3(sel3),
    .en4(en4),
    .en5(en5),
    .en6(en6),
    .en8(en8),
    .en9(en9),
    .en12(en12),
    .en15_0(en15_0),
    .en15_1(en15_1),
    .sel15(sel15),
    .en16_0(en16_0),
    .en16_1(en16_1),
    .sel16(sel16)
);
endmodule // reciprocal

module reciprocal_ctrl (
    // per node (target / initiator)
    input              clk,
    input              reset_n,
    input              t_0_req,
    output             t_0_ack,
    output             i_16_req,
    input              i_16_ack,
    output             en1_0,
    output             en1_1,
    output             sel1,
    output             en3_0,
    output             en3_1,
    output             sel3,
    output             en4,
    output             en5,
    output             en6,
    output             en8,
    output             en9,
    output             en12,
    output             en15_0,
    output             en15_1,
    output             sel15,
    output             en16_0,
    output             en16_1,
    output             sel16
);
wire             req0, ack0, ack0_0, req0_0, req1, ack1, ack1_0, req1_0, ack1_1, req1_1, req2, ack2, ack2_0, req2_0, req3, ack3, ack3_0, req3_0, ack3_1, req3_1, req4, ack4, ack4_0, req4_0, req5, ack5, ack5_0, req5_0, req6, ack6, ack6_0, req6_0, req7, ack7, ack7_0, req7_0, ack7_1, req7_1, req8, ack8, ack8_0, req8_0, req9, ack9, ack9_0, req9_0, req10, ack10, ack10_0, req10_0, req11, ack11, ack11_0, req11_0, req12, ack12, ack12_0, req12_0, req13, ack13, ack13_0, req13_0, req14, ack14, ack14_0, req14_0, req15, ack15, ack15_0, req15_0, req16, ack16, ack16_0, req16_0;
// node:t_0 target
assign req0 = t_0_req;
assign t_0_ack = ack0;
// edge:0 EB0
wire ack0m, req0m;
assign req0m = req0;
assign ack0 = ack0m;

// edge:0 fork
assign req0_0 = req0m;
assign ack0m = ack0_0;

// edge:1 EB1.5
wire ack1m, req1m;
eb15_ctrl uctrl_1 (
    .t_0_req(req1), .t_0_ack(ack1),
    .i_0_req(req1m), .i_0_ack(ack1m),
    .en0(en1_0), .en1(en1_1), .sel(sel1),
    .clk(clk), .reset_n(reset_n)
);

// edge:1 fork
reg  ack1_0_r, ack1_1_r;
wire ack1_0_s, ack1_1_s;
assign req1_0 = req1m & ~ack1_0_r;
assign req1_1 = req1m & ~ack1_1_r;
assign ack1_0_s = ack1_0 | ~req1_0;
assign ack1_1_s = ack1_1 | ~req1_1;
assign ack1m = ack1_0_s & ack1_1_s;
always @(posedge clk or negedge reset_n) if (~reset_n) ack1_0_r <= 1'b0; else ack1_0_r <= ack1_0_s & ~ack1m;
always @(posedge clk or negedge reset_n) if (~reset_n) ack1_1_r <= 1'b0; else ack1_1_r <= ack1_1_s & ~ack1m;
// edge:2 EB0
wire ack2m, req2m;
assign req2m = req2;
assign ack2 = ack2m;

// edge:2 fork
assign req2_0 = req2m;
assign ack2m = ack2_0;

// edge:3 EB1.5
wire ack3m, req3m;
eb15_ctrl uctrl_3 (
    .t_0_req(req3), .t_0_ack(ack3),
    .i_0_req(req3m), .i_0_ack(ack3m),
    .en0(en3_0), .en1(en3_1), .sel(sel3),
    .clk(clk), .reset_n(reset_n)
);

// edge:3 fork
reg  ack3_0_r, ack3_1_r;
wire ack3_0_s, ack3_1_s;
assign req3_0 = req3m & ~ack3_0_r;
assign req3_1 = req3m & ~ack3_1_r;
assign ack3_0_s = ack3_0 | ~req3_0;
assign ack3_1_s = ack3_1 | ~req3_1;
assign ack3m = ack3_0_s & ack3_1_s;
always @(posedge clk or negedge reset_n) if (~reset_n) ack3_0_r <= 1'b0; else ack3_0_r <= ack3_0_s & ~ack3m;
always @(posedge clk or negedge reset_n) if (~reset_n) ack3_1_r <= 1'b0; else ack3_1_r <= ack3_1_s & ~ack3m;
// edge:4 EB1
wire ack4m;
reg req4m;
assign en4 = req4 & ack4;
assign ack4 = ~req4m | ack4m;
always @(posedge clk or negedge reset_n) if (~reset_n) req4m <= 1'b0; else req4m <= ~ack4 | req4;

// edge:4 fork
assign req4_0 = req4m;
assign ack4m = ack4_0;
// edge:5 EB1
wire ack5m;
reg req5m;
assign en5 = req5 & ack5;
assign ack5 = ~req5m | ack5m;
always @(posedge clk or negedge reset_n) if (~reset_n) req5m <= 1'b0; else req5m <= ~ack5 | req5;

// edge:5 fork
assign req5_0 = req5m;
assign ack5m = ack5_0;
// edge:6 EB1
wire ack6m;
reg req6m;
assign en6 = req6 & ack6;
assign ack6 = ~req6m | ack6m;
always @(posedge clk or negedge reset_n) if (~reset_n) req6m <= 1'b0; else req6m <= ~ack6 | req6;

// edge:6 fork
assign req6_0 = req6m;
assign ack6m = ack6_0;
// edge:7 EB0
wire ack7m, req7m;
assign req7m = req7;
assign ack7 = ack7m;

// edge:7 fork
reg  ack7_0_r, ack7_1_r;
wire ack7_0_s, ack7_1_s;
assign req7_0 = req7m & ~ack7_0_r;
assign req7_1 = req7m & ~ack7_1_r;
assign ack7_0_s = ack7_0 | ~req7_0;
assign ack7_1_s = ack7_1 | ~req7_1;
assign ack7m = ack7_0_s & ack7_1_s;
always @(posedge clk or negedge reset_n) if (~reset_n) ack7_0_r <= 1'b0; else ack7_0_r <= ack7_0_s & ~ack7m;
always @(posedge clk or negedge reset_n) if (~reset_n) ack7_1_r <= 1'b0; else ack7_1_r <= ack7_1_s & ~ack7m;
// edge:8 EB1
wire ack8m;
reg req8m;
assign en8 = req8 & ack8;
assign ack8 = ~req8m | ack8m;
always @(posedge clk or negedge reset_n) if (~reset_n) req8m <= 1'b0; else req8m <= ~ack8 | req8;

// edge:8 fork
assign req8_0 = req8m;
assign ack8m = ack8_0;
// edge:9 EB1
wire ack9m;
reg req9m;
assign en9 = req9 & ack9;
assign ack9 = ~req9m | ack9m;
always @(posedge clk or negedge reset_n) if (~reset_n) req9m <= 1'b0; else req9m <= ~ack9 | req9;

// edge:9 fork
assign req9_0 = req9m;
assign ack9m = ack9_0;
// edge:10 EB0
wire ack10m, req10m;
assign req10m = req10;
assign ack10 = ack10m;

// edge:10 fork
assign req10_0 = req10m;
assign ack10m = ack10_0;
// edge:11 EB0
wire ack11m, req11m;
assign req11m = req11;
assign ack11 = ack11m;

// edge:11 fork
assign req11_0 = req11m;
assign ack11m = ack11_0;
// edge:12 EB1
wire ack12m;
reg req12m;
assign en12 = req12 & ack12;
assign ack12 = ~req12m | ack12m;
always @(posedge clk or negedge reset_n) if (~reset_n) req12m <= 1'b0; else req12m <= ~ack12 | req12;

// edge:12 fork
assign req12_0 = req12m;
assign ack12m = ack12_0;
// edge:13 EB0
wire ack13m, req13m;
assign req13m = req13;
assign ack13 = ack13m;

// edge:13 fork
assign req13_0 = req13m;
assign ack13m = ack13_0;
// edge:14 EB0
wire ack14m, req14m;
assign req14m = req14;
assign ack14 = ack14m;

// edge:14 fork
assign req14_0 = req14m;
assign ack14m = ack14_0;

// edge:15 EB1.5
wire ack15m, req15m;
eb15_ctrl uctrl_15 (
    .t_0_req(req15), .t_0_ack(ack15),
    .i_0_req(req15m), .i_0_ack(ack15m),
    .en0(en15_0), .en1(en15_1), .sel(sel15),
    .clk(clk), .reset_n(reset_n)
);

// edge:15 fork
assign req15_0 = req15m;
assign ack15m = ack15_0;

// edge:16 EB1.5
wire ack16m, req16m;
eb15_ctrl uctrl_16 (
    .t_0_req(req16), .t_0_ack(ack16),
    .i_0_req(req16m), .i_0_ack(ack16m),
    .en0(en16_0), .en1(en16_1), .sel(sel16),
    .clk(clk), .reset_n(reset_n)
);

// edge:16 fork
assign req16_0 = req16m;
assign ack16m = ack16_0;
// node:1 join =
// join:1, fork:1
assign req1 = req0_0;
assign ack0_0 = ack1;
// node:2 join lzc
// join:1, fork:1
assign req2 = req1_0;
assign ack1_0 = ack2;
// node:3 join normalize
// join:2, fork:2
wire             req3_q, ack1_1_m;
assign req3_q = req1_1 & req2_0;
reg        [1:0] ack3_r;
wire       [1:0] req3_c, ack3_s;
assign req3_c = ~ack3_r & {2{req3_q}};
assign {req4, req3} = req3_c;
assign ack3_s = {ack4, ack3} | ~req3_c;
assign ack1_1_m = &ack3_s;
always @(posedge clk or negedge reset_n) if (~reset_n) ack3_r <= 2'b0; else ack3_r <= ack3_s & ~{2{ack1_1_m}};
assign ack1_1 = ack1_1_m & req2_0;
assign ack2_0 = ack1_1_m & req1_1;
// node:4 join =
// join:1, fork:1
assign req5 = req4_0;
assign ack4_0 = ack5;
// node:5 join =
// join:1, fork:1
assign req6 = req5_0;
assign ack5_0 = ack6;
// node:6 join lhsOp
// join:1, fork:1
assign req7 = req3_0;
assign ack3_0 = ack7;
// node:7 join =
// join:1, fork:1
assign req8 = req7_0;
assign ack7_0 = ack8;
// node:8 join *
// join:2, fork:1
assign req9 = req3_1 & req7_1;
assign ack3_1 = ack9 & req7_1;
assign ack7_1 = ack9 & req3_1;
// node:9 join bitSelect
// join:1, fork:1
assign req10 = req9_0;
assign ack9_0 = ack10;
// node:10 join lhsOp
// join:1, fork:1
assign req11 = req10_0;
assign ack10_0 = ack11;
// node:11 join *
// join:2, fork:1
assign req12 = req11_0 & req8_0;
assign ack11_0 = ack12 & req8_0;
assign ack8_0 = ack12 & req11_0;
// node:12 join bitSelect
// join:1, fork:1
assign req13 = req12_0;
assign ack12_0 = ack13;
// node:13 join reciprocalSatShift2
// join:1, fork:1
assign req14 = req13_0;
assign ack13_0 = ack14;
// node:14 join renorm
// join:2, fork:1
assign req15 = req14_0 & req6_0;
assign ack14_0 = ack15 & req6_0;
assign ack6_0 = ack15 & req14_0;
// node:15 join reciprocalSat
// join:1, fork:1
assign req16 = req15_0;
assign ack15_0 = ack16;
// node:16 initiator
assign i_16_req = req16_0;
assign ack16_0 = i_16_ack;
endmodule // reciprocal_ctrl
