//
// inteface
//
interface intf();
  logic        clk;
  logic        rst_n;
  logic        wr_n;
  logic [7:0]  addr;
  logic [31:0] dat;
endinterface // inf

//
// uvm test
//
import uvm_pkg::*;
`include "uvm_macros.svh"

class uvm_intf extends uvm_test;
  `uvm_component_utils(uvm_intf)
  
  virtual intf v_intf;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);

    //get interface pointer from config_db and assign to virtual intf.
    uvm_config_db #(virtual intf)::get(null, "uvm_test_top", "u_intf", v_intf);

    //initial v_intf
    v_intf.clk = 1'b0;
    v_intf.rst_n = 1'b0;
    v_intf.wr_n = 1'b0;
    v_intf.addr = 8'b0;
    v_intf.dat = 32'b0;

    //generate stimulus and drive to RTL
    fork
      begin: CLK
        forever
          begin
            v_intf.clk = 1'b0; #10;
            v_intf.clk = 1'b1; #10;
          end
      end
      begin: RST
        v_intf.rst_n = 1'b0; #100;
        v_intf.rst_n = 1'b1;
      end
      begin: WRITE
        #200;
        repeat(20)
          begin
            @(negedge v_intf.clk);
            v_intf.wr_n = $random;
            v_intf.addr = $random;
            v_intf.dat = $random;
          end
        disable CLK;
      end
    join

    phase.drop_objection(this);
  endtask // main_phase
  
endclass // uvm_intf

//
// testbench top wrapper
//
module tb 
  ();
  
  import uvm_pkg::*;
`include "uvm_macros.svh"

  //define some local logic signals in RTL
  wire        rtl_clk;
  wire        rtl_rst_n;
  wire        rtl_wr_n;
  wire [7:0]  rtl_addr;
  wire [31:0] rtl_dat;  

  //instance of interface, which is like a module
  intf u_intf();

  //connect interface to RTL
  assign rtl_clk   = u_intf.clk;
  assign rtl_rst_n = u_intf.rst_n;
  assign rtl_wr_n  = u_intf.wr_n;
  assign rtl_addr  = u_intf.addr;
  assign rtl_dat   = u_intf.dat;

  // set u_intf to uvm_test_top, that is the uvm_test.
  // and start run_test
  initial begin
    uvm_config_db #(virtual intf)::set(null, "uvm_test_top", "u_intf", u_intf);
    run_test("uvm_intf");
  end

  // Dump fsdb format waveform
  initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, tb);
  end
  
endmodule // tb

