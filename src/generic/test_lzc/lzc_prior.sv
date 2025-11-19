module lzc_prior #(parameter WIDTH = 23) (
  input  logic [WIDTH-1:0]            num,    // number to count the leading zeroes of
  output logic [$clog2(WIDTH+1)-1:0]  ZeroCnt // the number of leading zeroes
);

  integer i;

  always_comb begin
    i = 0;
    while ((i < WIDTH) & ~num[WIDTH-1-i]) i = i+1;  // search for leading one
    ZeroCnt = i[$clog2(WIDTH+1)-1:0];
  end
endmodule
