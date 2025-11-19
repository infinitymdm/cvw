module tb;

  localparam VEC_LEN=`VLEN;

  logic clk;
  int   leading_zeros;
  int   error_count_dut1, error_count_dut2;
  bit [0:+VEC_LEN]          num;
  bit [0:$clog2(VEC_LEN+1)] zero_count_ref, zero_count_dut1, zero_count_dut2;

  lzc       #(VEC_LEN) dut1      (num, zero_count_dut1);
  lzc_unopt #(VEC_LEN) dut2      (num, zero_count_dut2);
  lzc_prior #(VEC_LEN) reference (num, zero_count_ref);

  initial begin: dump_fst
    $dumpfile("wave.fst");
    $dumpvars;
  end

  initial begin: initialize
    clk = 1'b0;
    num = 'b0;
    error_count_dut1 = 0;
    error_count_dut2 = 0;
  end
  always #5 clk <= ~clk;

  always @(posedge clk) begin: stimulate
    void'(std::randomize(leading_zeros));
    num = {1'b1, $urandom} >> leading_zeros;
  end

  always @(negedge clk) begin: check
    if (zero_count_dut1 != zero_count_ref) begin
      $display("%b | dut1: %d, exp: %d  FAIL", num, zero_count_dut1, zero_count_ref);
      error_count_dut1++;
    end
    if (zero_count_dut2 != zero_count_ref) begin
        $display("%b | dut2: %d, exp: %d  FAIL", num, zero_count_dut2, zero_count_ref);
        error_count_dut2++;
    end
  end

  initial begin: exit_clause
    #10000000; // exit after a million iterations
    $display("ERROR COUNTS (VLEN = %0d)", `VLEN);
    $display("dut1: %d", error_count_dut1);
    $display("dut2: %d", error_count_dut2);
    $finish;
  end

endmodule
