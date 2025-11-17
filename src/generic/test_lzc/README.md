# LZC Experiments

This folder contains a set of reproducible synthesis and timing experiments comparing the current
(`while`-loop-based) leading zero counter (LZC) to a recursive binary tree implementation.

The pull request motivating these experiments can be found here: https://github.com/openhwgroup/cvw/pull/1396/

## Synthesis Results

Results are based on minimal synthesis procedures. Device-independent synthesis flows are used when
available; otherwise, defaults are used.

:x: = Synthesis fails with an error.

:white_check_mark: = Synthesis succeeds.

-- = not yet tested.


| Synthesis Tool                     | Prior Design       | Recursive Design   |
| ---------------------------------- | ------------------ | ------------------ |
| yosys 0.59.1                       | :x:                | :white_check_mark: |
| AMD Vivado 2024.2                  | :white_check_mark: | :white_check_mark: |
| Synopsys Design Compiler X-2025.06 | --                 | --                 |
| Intel Quartus Prime Lite 25.1      | --                 | --                 |
| Cadence Genus 21.16                | --                 | --                 |
