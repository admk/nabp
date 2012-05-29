{# include('templates/defines.v') #}
// NABPImageRAM
module NABPImageRAM
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from image addresser
    input wire ir_kick,
    input wire ir_done,
    input wire [`kImageAddressLength-1:0] ir_addr,
    input wire [`kCacheDataLength-1:0] ir_val,
    // output to image addresser & processing elements
    output wire ir_enable
);



endmodule
