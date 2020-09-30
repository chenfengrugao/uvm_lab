import uvm_pkg::*;
`include "uvm_macros.svh"

class hello_world extends uvm_test;
  `uvm_component_utils(hello_world)

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction // new

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    phase.raise_objection(this);
    
    `uvm_info(this.get_name(), "Hello world from UVM", UVM_LOW)

    phase.drop_objection(this);
  endtask // main_phase
  
endclass // hello_world

module tb 
  ();
  
  import uvm_pkg::*;
`include "uvm_macros.svh"

  initial begin
    run_test("hello_world");
  end

endmodule // tb



