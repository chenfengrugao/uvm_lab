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

class bus_driver extends uvm_driver;
  `uvm_component_utils(bus_driver)

  virtual intf v_intf;
  
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new

  function void build_phase(uvm_phase phase);
    //super.build_phase(phase);
    
    //get from uvm_test
    if(!uvm_config_db #(virtual intf)::get(this, "", "u_intf", v_intf))
      `uvm_fatal("bus_driver", "can not get interface from tb")
    
  endfunction // build_phase
  
  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);

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
  
endclass: bus_driver

class my_test extends uvm_test;
  `uvm_component_utils(my_test)
  
  virtual intf v_intf;
  bus_driver my_driver;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new

  function void build_phase(uvm_phase phase);
    //super.build_phase(phase);
    
    my_driver = bus_driver::type_id::create("my_driver", this);
      
    //get from tb
    if(!uvm_config_db #(virtual intf)::get(this, "", "u_intf", v_intf))
      `uvm_fatal("my_test", "can not get interface from tb")
    //set to driver
    uvm_config_db #(virtual intf)::set(this, "my_driver", "u_intf", v_intf);
    
  endfunction
  
  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);

    phase.drop_objection(this);
  endtask // main_phase
  
endclass: my_test

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
    run_test();
  end

  // Dump fsdb format waveform
  initial begin
    $fsdbDumpfile("tb.fsdb");
    $fsdbDumpvars(0, tb);
  end
  
endmodule // tb

