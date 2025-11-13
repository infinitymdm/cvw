module tb;

  localparam VEC_LEN=23;

  logic clk;
  int   leading_zeros;
  int   error_count;
  bit [0:+VEC_LEN]          num;
  bit [0:$clog2(VEC_LEN+1)] zero_count_ref, zero_count_dut;

  lzc #(VEC_LEN) dut (num, zero_count_dut);
  lzc_prior #(VEC_LEN) reference (num, zero_count_ref);

  initial begin: dump_fst
    $dumpfile("wave.fst");
    $dumpvars;
  end

  initial begin: initialize
    clk = 1'b0;
    num = 'b0;
    error_count = 0;
  end
  always #5 clk <= ~clk;

  always @(posedge clk) begin: stimulate
    void'(std::randomize(leading_zeros));
    num = {1'b1, $urandom} >> leading_zeros;
  end

  always @(negedge clk) begin: check
    if (zero_count_dut != zero_count_ref) begin
      $display("%b | dut: %d, exp: %d  FAIL", num, zero_count_dut, zero_count_ref);
      error_count++;
    end
  end

  initial begin: exit_clause
    #10000000; // exit after a million iterations
    $display("Errors: %d", error_count);
    $finish;
  end

endmodule
