`ifndef I2C_IF_SV
`define I2C_IF_SV

interface i2c_if;
    
    tri1 scl;
    tri1 sda;
    
    logic sda_out;
    logic sda_oe;
    
    assign sda = sda_oe ? sda_out : 1'bz;

endinterface

`endif