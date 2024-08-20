///////////////////////////////////////////
// wally-pipelinedsoc.sv
//
// Written: David_Harris@hmc.edu 6 November 2020
// Modified: 
//
// Purpose: System on chip including pipelined processor and uncore memories/peripherals
//
// Documentation: RISC-V System on Chip Design
//
// A component of the CORE-V-WALLY configurable RISC-V project.
// https://github.com/openhwgroup/cvw
// 
// Copyright (C) 2021-23 Harvey Mudd College & Oklahoma State University
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-2.1
//
// Licensed under the Solderpad Hardware License v 2.1 (the “License”); you may not use this file 
// except in compliance with the License, or, at your option, the Apache License version 2.0. You 
// may obtain a copy of the License at
//
// https://solderpad.org/licenses/SHL-2.1/
//
// Unless required by applicable law or agreed to in writing, any work distributed under the 
// License is distributed on an “AS IS” BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
// either express or implied. See the License for the specific language governing permissions 
// and limitations under the License.
////////////////////////////////////////////////////////////////////////////////////////////////

module wallypipelinedsoc 
  import cvw::*;
#(
  parameter cvw_t P
)  (
  input  logic                clk, 
  input  logic                reset_ext,        // external asynchronous reset pin
  output logic                reset,            // reset synchronized to clk to prevent races on release
  // AHB Interface
  input  logic [P.AHBW-1:0]     HRDATAEXT,
  input  logic                HREADYEXT, HRESPEXT,
  output logic                HSELEXT,
  output logic                HSELEXTSDC, 
  // outputs to external memory, shared with uncore memory
  output logic                HCLK, HRESETn,
  output logic [P.PA_BITS-1:0]  HADDR,
  output logic [P.AHBW-1:0]     HWDATA,
  output logic [P.XLEN/8-1:0]   HWSTRB,
  output logic                HWRITE,
  output logic [2:0]          HSIZE,
  output logic [2:0]          HBURST,
  output logic [3:0]          HPROT,
  output logic [1:0]          HTRANS,
  output logic                HMASTLOCK,
  output logic                HREADY,
  // I/O Interface
  input  logic                TIMECLK,          // optional for CLINT MTIME counter
  input  logic [31:0]         GPIOIN,           // inputs from GPIO
  output logic [31:0]         GPIOOUT,          // output values for GPIO
  output logic [31:0]         GPIOEN,           // output enables for GPIO
  input  logic                UARTSin,          // UART serial data input
  output logic                UARTSout,         // UART serial data output
  input  logic                SDCIntr,
  input  logic                SPIIn,            // SPI pins in
  output logic                SPIOut,           // SPI pins out
  output logic [3:0]          SPICS,            // SPI chip select pins        
  input  logic                ui_clk,
  output logic [15:0]         dmc_trefi,
  output logic [3:0]          dmc_tmrd,
  output logic [3:0]          dmc_trfc,
  output logic [3:0]          dmc_trc,
  output logic [3:0]          dmc_trp,
  output logic [3:0]          dmc_tras,
  output logic [3:0]          dmc_trrd,
  output logic [3:0]          dmc_trcd,
  output logic [3:0]          dmc_twr,
  output logic [3:0]          dmc_twtr,
  output logic [3:0]          dmc_trtp,
  output logic [3:0]          dmc_tcas,
  output logic [3:0]          dmc_col_width,
  output logic [3:0]          dmc_row_width,
  output logic [1:0]          dmc_bank_width,
  output logic [5:0]          dmc_bank_pos,
  output logic [2:0]          dmc_dqs_sel_cal,
  output logic [15:0]         dmc_init_cycles,
  output logic                dmc_config_changed,
  input  logic                PLLrefclk,
  input  logic                PLLrfen,
  input  logic                PLLfben,
  output logic [5:0]          PLLclkr,
  output logic [12:0]         PLLclkf,
  output logic [3:0]          PLLclkod,
  output logic [11:0]         PLLbwadj,
  input  logic                PLLlock,
  output logic                PLLconfigdone
);

  // Uncore signals
  logic [P.AHBW-1:0]          HRDATA;           // from AHB mux in uncore
  logic                       HRESP;            // response from AHB
  logic                       MTimerInt, MSwInt;// timer and software interrupts from CLINT
  logic [63:0]                MTIME_CLINT;      // from CLINT to CSRs
  logic                       MExtInt,SExtInt;  // from PLIC

  // synchronize reset to SOC clock domain
  synchronizer resetsync(.clk, .d(reset_ext), .q(reset)); 
   
  // instantiate processor and internal memories
  wallypipelinedcore #(P) core(.clk, .reset,
    .MTimerInt, .MExtInt, .SExtInt, .MSwInt, .MTIME_CLINT,
    .HRDATA, .HREADY, .HRESP, .HCLK, .HRESETn, .HADDR, .HWDATA, .HWSTRB,
    .HWRITE, .HSIZE, .HBURST, .HPROT, .HTRANS, .HMASTLOCK
   );

  // instantiate uncore if a bus interface exists
  if (P.BUS_SUPPORTED) begin : uncoregen // Hack to work around Verilator bug https://github.com/verilator/verilator/issues/4769
    uncore #(P) uncore (
      .HCLK, .HRESETn, .TIMECLK,
      .HADDR, .HWDATA, .HWSTRB, .HWRITE, .HSIZE, .HBURST, .HPROT, .HTRANS, .HMASTLOCK, .HRDATAEXT,
      .HREADYEXT, .HRESPEXT, .HRDATA, .HREADY, .HRESP, .HSELEXT, .HSELEXTSDC,
      .MTimerInt, .MSwInt, .MExtInt, .SExtInt, .GPIOIN, .GPIOOUT, .GPIOEN, .UARTSin, 
      .UARTSout, .MTIME_CLINT, .SDCIntr, .SPIIn, .SPIOut, .SPICS,
      .ui_clk, .dmc_trefi, .dmc_tmrd, .dmc_trfc, .dmc_trc, .dmc_trp, .dmc_tras, .dmc_trrd,
      .dmc_trcd, .dmc_twr, .dmc_twtr, .dmc_trtp, .dmc_tcas, .dmc_col_width, .dmc_row_width,
      .dmc_bank_width, .dmc_bank_pos, .dmc_dqs_sel_cal, .dmc_init_cycles, .dmc_config_changed,
      .PLLrefclk, .PLLrfen, .PLLfben, .PLLclkr, .PLLclkf, .PLLclkod, .PLLbwadj,
      .PLLlock, .PLLconfigdone
    );
  end else begin
    assign {HRDATA, HREADY, HRESP, HSELEXT, HSELEXTSDC, MTimerInt, MSwInt, MExtInt, SExtInt,
            MTIME_CLINT, GPIOOUT, GPIOEN, UARTSout, SPIOut, SPICS, dmc_trefi, dmc_tmrd, dmc_trfc,
            dmc_trc, dmc_trp, dmc_tras, dmc_trrd, dmc_trcd, dmc_twr, dmc_twtr, dmc_trtp, dmc_tcas,
            dmc_col_width, dmc_row_width, dmc_bank_width, dmc_bank_pos, dmc_dqs_sel_cal,
            dmc_init_cycles, PLLclkr, PLLclkf, PLLclkod, PLLbwadj} = '0;
  end

endmodule
