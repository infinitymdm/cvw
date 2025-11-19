module lzc_unopt #(parameter WIDTH = 1) (
  input  logic [WIDTH-1:0]           num,    // number to count the leading zeroes of
  output logic [$clog2(WIDTH+1)-1:0] ZeroCnt // the number of leading zeroes
);

  // Use a recursive binary tree structure to avoid unsynthesizable loops
  localparam LWIDTH = WIDTH - WIDTH/2; // May be 1 bit larger than WIDTH/2 due to floor division
  localparam RWIDTH = WIDTH/2;
  logic [LWIDTH-1:0] LNum;
  logic [RWIDTH-1:0] RNum;
  logic [$clog2(LWIDTH+1):0] LCnt;
  logic [$clog2(RWIDTH+1):0] RCnt;

  assign {LNum, RNum} = num;
  generate
    if (WIDTH == 1)
      assign ZeroCnt = ~num;
    else begin
      lzc_unopt #(LWIDTH) l_lcz (LNum, LCnt);
      lzc_unopt #(RWIDTH) r_lcz (RNum, RCnt);
      assign ZeroCnt = (LCnt == LWIDTH) ? LCnt + RCnt: LCnt;
    end
  endgenerate

endmodule
