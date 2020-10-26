
irun -sv \
    -64bit \
    -uvmhome /eda/ius141/tools/methodology/UVM/CDNS-1.2/sv \
    -access rwc \
    +UVM_TESTNAME=my_test \
    +UVM_CONFIG_DB_TRACE \
    uvm_driver.sv

    
