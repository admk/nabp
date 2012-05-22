{# include('templates/defines.v') #}
// NABPImageAddresser
//     22 May 2012
// The image address generator for PE domino feed values.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

module NABPImageAddresser
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from Image RAM
    input wire ir_kick,
    input wire ir_enable,
    // outputs to image RAM
    output wire ir_done,
    output wire [`kImageAddressLength-1:0] ir_addr,
)

endmodule
