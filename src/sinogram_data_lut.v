{# include('templates/defines.v') #}
// NABPSinogramDataLUT
//     8 Mar 2012
// This module provides sinogram test data for testing purposes.

{#
    if not c['debug']:
        raise RuntimeError('Must be in debug mode to use this module.')
#}

module NABPSinogramDataLUT
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from nabp
    input wire [`kSinogramAddressLength-1:0] sg_addr,
    // outputs to nabp
    output reg [`kDataLength-1:0] sg_val
);

always @(posedge clk)
begin
    {# set_eat_blanklines(True) #}
    case (sg_addr)
        {% for key, val in c['lutSinogram'].iteritems() %}
            {# key #}:
                sg_val <= {# val #};
        {% end %}
    endcase
    {# set_eat_blanklines(False) #}
end

endmodule
