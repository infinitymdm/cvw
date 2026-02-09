module lzc #(parameter int WIDTH = 23) (
  input  logic [WIDTH-1:0]                 num,
  output logic [$clog2(WIDTH+1)-1:0]       ZeroCnt
);

  localparam CBITS = $clog2(WIDTH+1);

   generate
      if (WIDTH == 1) begin : g_w1
	 always_comb ZeroCnt = CBITS'((num[0] == 1'b0) ? 1 : 0);
      end
      else if (WIDTH == 2) begin : g_w2
	 always_comb begin
            unique casez (num)
              2'b1?: ZeroCnt = CBITS'(0);
              2'b01: ZeroCnt = CBITS'(1);
              default: ZeroCnt = CBITS'(2);
            endcase
	 end
      end
      else begin : g_tree
	 localparam WL = WIDTH/2;
	 localparam WU = WIDTH - WL;

	 logic [$clog2(WU+1)-1:0] zU;
	 logic [$clog2(WL+1)-1:0] zL;

	 // Upper = [WIDTH-1:WL], Lower = [WL-1:0]
	 lzc #(.WIDTH(WU)) u_lzcU (.num(num[WIDTH-1:WL]), .ZeroCnt(zU));
	 lzc #(.WIDTH(WL)) u_lzcL (.num(num[WL-1:0]),     .ZeroCnt(zL));

	 logic			  upper_any;
	 // avoids wide OR and uses priority structure
	 localparam		  UCBITS = $clog2(WU+1);
	 assign upper_any = (zU != UCBITS'(WU));
	 always_comb begin
            if (upper_any)
              ZeroCnt = CBITS'(zU);
            else
              ZeroCnt = CBITS'(WU) + CBITS'(zL);
	 end
      end
   endgenerate

endmodule // lzc
