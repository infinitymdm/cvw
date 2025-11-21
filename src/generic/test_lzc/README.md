# LZC Experiments

This folder contains a set of reproducible synthesis and timing experiments comparing the current
(`while`-loop-based) leading zero counter (LZC) to a recursive binary tree implementation.

The pull request motivating these experiments can be found here: https://github.com/openhwgroup/cvw/pull/1396/

## Designs

The experiments in this branch evaluate three LZC designs:
+ Prior: the current `while`-loop-based design ([sv source](https://github.com/infinitymdm/cvw/blob/lzc_tests/src/generic/test_lzc/lzc_prior.sv)).
+ Recursive (unoptimized): a new design based on a recursive binary tree ([sv source](https://github.com/infinitymdm/cvw/blob/lzc_tests/src/generic/test_lzc/lzc_unopt.sv)).
+ Recursive (optimized): an modified version of the recursive binary tree design above with
    slightly different splitting logic and an `AllZeros` output ([sv source](https://github.com/infinitymdm/cvw/blob/lzc_tests/src/generic/lzc.sv)).

## Synthesis Results

Results are based on minimal synthesis procedures. Device-independent synthesis flows are used when
available; otherwise, defaults are used.

| Synthesis Tool                     | Prior              | Recursive (unoptimized) | Recursive (optimized) |
| ---------------------------------- | ------------------ | ----------------------- | --------------------- |
| yosys 0.59.1                       | :x:                | :white_check_mark:      | :white_check_mark:    |
| AMD Vivado 2024.2                  | :white_check_mark: | :white_check_mark:      | :white_check_mark:    |
| Intel Quartus Prime Lite 25.1      | :x:                | :white_check_mark:      | :white_check_mark:    |
| Synopsys Design Compiler X-2025.06 | :white_check_mark: | :white_check_mark:      | :white_check_mark:    |
| Cadence Genus 21.16                | :white_check_mark: | :white_check_mark:      | :white_check_mark:    |

- :x: = Synthesis fails with an error.
- :white_check_mark: = Synthesis succeeds.

## Power, Performance, & Area (PPA) Results

### AMD Vivado 2024.2

The default `xc7k70tfbv676-1` part was used for each design.

| Design                  | Area (LUTs used) | Datapath Delay (ns) | On-Chip Power (W) |
| ----------------------- | ---------------- | ------------------- | ----------------- |
| Prior                   | 19               | 5.336               | 1.211             |
| Recursive (unoptimized) | 22               | 5.343               | 1.270             |
| Recursive (optimized)   | 19               | 5.336               | 1.211             |

### Intel Quartus Prime Lite 25.1

The default `5CGXFC7C7F23C8` part was used for each design.

| Design                  | Area (ALMs used)       | Datapath Delay |
| ----------------------- | ---------------------- | -------------- |
| Prior                   | N/A (failed synthesis) | N/A            |
| Recursive (unoptimized) | 35                     | 16.897         |
| Recursive (optimized)   | 16                     | 16.605         |

### Synopsys Design Compiler X-2025.06

All designs were synthesized against the TSMC N28 PDK.

| Design                  | Combinational Area | Combinational Power | Datapath Delay |
| ----------------------- | -------------------| ------------------- | -------------- |
| Prior                   | 19.404             | 3.104e-3 mW         | 0.17           |
| Recursive (unoptimized) | 13.230             | 1.809e-3 mW         | 0.19           |
| Recursive (optimized)   | 4.536              | 1.104e-3 mW         | 0.02           |

### Cadence Genus 21.16

All designs were synthesized against the TSMC N28 PDK.

| Design                  | Combinational Area | Combinational Power | Datapath Delay |
| ----------------------- | ------------------ | ------------------- | -------------- |
| Prior                   | 92.527             | 4.621e-7 W          | 132 ps         |
| Recursive (unoptimized) | 92.527             | 4.815e-7 W          | 125 ps         |
| Recursive (optimized)   | 96.032             | 4.696e-7 W          | 118 ps         |

## Replicating the Results

In order to reproduce these results you must have access to each of the tools specified. The FPGA
tools used here are freely available, but the ASIC tools require a license.

For convenience, the commands used to produce each result are stored as recipes in a justfile. If
the `just` program is available for your system, you can install it and easily run the relevant
recipes. Otherwise you can copy & paste commands from the justfile.
