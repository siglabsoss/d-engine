module vcordic
  (input wire [15:0] t_x,
   input wire [15:0] t_y,
   input wire        t_valid,
   output reg        t_ready,

   output reg [15:0] i_mag,
   output reg [15:0] i_angle,
   output reg        i_valid,
   input wire        i_ready,

   input wire        clk, rstf
   );

   logic             out_ready;
   logic [16:0]      theta[16];

   assign t_ready = out_ready;
   
   assign theta = '{17'b00100000000000000,
                    17'b00010010111001000,
                    17'b00001001111110110,
                    17'b00000101000100010,
                    17'b00000010100010110,
                    17'b00000001010001011,
                    17'b00000000101000101,
                    17'b00000000010100010,
                    17'b00000000001010001,
                    17'b00000000000101000,
                    17'b00000000000010100,
                    17'b00000000000001010,
                    17'b00000000000000101,
                    17'b00000000000000010,
                    17'b00000000000000001,
                    17'b00000000000000000};


   /*
    if(yinit[17]) begin
    z0 <= zinit - theta[0];
    x0 <= xinit - yinit;
    y0 <= yinit + xinit;
        end
    else begin
    z0 <= zinit + theta[0];
    x0 <= xinit + yinit;
    y0 <= yinit - xinit;
        end
    */

   function logic [17:0] xcalc(logic[17:0] xval, logic[17:0] xremval, logic[17:0] yval, logic[17:0] yremval, logic neg, integer rshift);
      if(neg)
        return ($signed(xval) - $signed(yremval)) >>> rshift;
      else
        return ($signed(xval) + $signed(yremval)) >>> rshift;
   endfunction
   
   function logic [17:0] ycalc(logic[17:0] xval, logic[17:0] xremval, logic[17:0] yval, logic[17:0] yremval, logic neg, integer rshift);
      if(neg)
        return ($signed(yval) + $signed(xremval)) >>> rshift;
      else
        return ($signed(yval) - $signed(xremval)) >>> rshift;
   endfunction

   function logic [16:0] zcalc(logic[16:0] zval, logic[16:0] theta_val, logic neg);
      if(neg)
        return $signed(zval) - $signed(theta_val);
      else
        return $signed(zval) + $signed(theta_val);
   endfunction

   
   logic [17:0]      xinit, yinit;
   logic [17:0]      x_reminit, y_reminit;
   logic [1:0]       sign_init;
   logic [16:0]      zinit;
   logic             valid_init;

   //Stage Init
   always @(posedge clk or negedge rstf) begin
      if(~rstf) begin
         valid_init <= 0;
      end else begin
         if(out_ready)
           valid_init <= t_valid;
         if(t_valid & out_ready) begin
            if(t_x[15]) begin
               xinit <= {2'b0, ~t_x};
               x_reminit <= {2'b0, ~t_x};
            end
            else begin
               xinit <= {2'b0, t_x};
               x_reminit <= {2'b0, t_x};
            end
            yinit <= { {2{t_y[15]}}, t_y};
            y_reminit <= { {2{t_y[15]}}, t_y};
            sign_init <= {t_y[15], t_x[15]};
            zinit <= 0;
         end // if (t_valid && i_ready)
      end // else: !if(~rstf)
   end

   logic [17:0] x[16];
   logic [17:0] xrem[16];
   logic [17:0] y[16];
   logic [17:0] yrem[16];
   logic [16:0] z[16];
   logic [1:0]  sign[16];
   logic        valid[16];
   
   //Stage 0
   always @(posedge clk or negedge rstf) begin
      if(~rstf) begin
         valid[0] <= 0;
      end else begin
         if(out_ready)
           valid[0] <= valid_init;
         if(valid_init & out_ready) begin
            z[0] <= zcalc(zinit, theta[0], yinit[17]);
            xrem[0] <= xcalc(xinit, x_reminit, yinit, y_reminit, yinit[17], 1);
            x[0] <= xcalc(xinit, x_reminit, yinit, y_reminit, yinit[17], 0);
            yrem[0] <= ycalc(xinit, x_reminit, yinit, y_reminit, yinit[17], 1);
            y[0] <= ycalc(xinit, x_reminit, yinit, y_reminit, yinit[17], 0);
            sign[0] <= sign_init;
         end // if (t_valid && i_ready)
      end // else: !if(~rstf)
   end

   genvar i;

   generate
      for(i = 1; i < 16; i++) begin
         //Stage 1
         always @(posedge clk or negedge rstf) begin
            if(~rstf) begin
               valid[i] <= 0;
            end else begin
               if(out_ready)
                 valid[i] <= valid[i-1];
               if(valid[i-1] & out_ready) begin
                  z[i] <= zcalc(z[i-1], theta[i], y[i-1][17]);
                  xrem[i] <= xcalc(x[i-1], xrem[i-1], y[i-1], yrem[i-1], y[i-1][17], i+1);
                  x[i] <= xcalc(x[i-1], xrem[i-1], y[i-1], yrem[i-1], y[i-1][17], 0);
                  yrem[i] <= ycalc(x[i-1], xrem[i-1], y[i-1], yrem[i-1], y[i-1][17], i+1);
                  y[i] <= ycalc(x[i-1], xrem[i-1], y[i-1], yrem[i-1], y[i-1][17], 0);
                  sign[i] <= sign[i-1];
               end // if (t_valid && i_ready)
            end // else: !if(~rstf)
         end // always @ (posedge clk or negedge rstf)
      end
   endgenerate

   logic [17:0] xsat;
   logic [16:0] zsat;
   logic [1:0]  sign_sat;
   logic        valid_sat;
   
   //Saturate
   always @(posedge clk or negedge rstf) begin
      if(~rstf) begin
         valid_sat <= 0;
      end else begin
         if(out_ready)
           valid_sat <= valid[15];
         if(valid[15] & out_ready) begin
            if(z[15][16] != z[15][15]) 
              zsat <= { {2{z[15][16]}}, {15{~z[15][16]}}};
            else
              zsat <= z[15];
            xsat <= x[15];
            sign_sat <= sign[15];
         end
      end // else: !if(~rstf)
   end


   logic [17:0] xnorm;
   logic [16:0] znorm;
   logic        valid_norm;

   //Normalize
   always @(posedge clk or negedge rstf) begin
      if(~rstf) begin
         valid_norm <= 0;
      end else begin
         if(out_ready)
           valid_norm <= valid_sat;
         if(valid_sat & out_ready) begin
            if(sign_sat[0] & ~zsat[15]) begin
              znorm <= 16'h7FFF - (zsat >> 1);
            end else if(sign_sat[0] & zsat[15]) begin
              znorm <= 16'h8000 - (zsat >> 1);
            end else begin
              znorm <= zsat >> 1;
            end
            xnorm <= xsat;
         end
      end // else: !if(~rstf)
   end

   eb15 eb15_out
     (.t_data({xnorm[17:2],znorm[15:0]}),
      .t_valid(valid_norm),
      .t_ready(out_ready),
      .i_data({i_mag,i_angle}),
      .i_valid(i_valid),
      .i_ready(i_ready),
      .clk(clk),
      .rstf(rstf)
      );
   
   //Output
   /*always @(posedge clk or negedge rstf) begin
    if(~rstf) begin
    i_valid <= 0;
      end else begin
    if(valid_sat & i_ready) begin
    i_mag <= xnorm[17:2];
    i_angle <= znorm[15:0];
    i_valid <= valid_norm;
         end
      end
   end*/
   
   
endmodule
