{# include('templates/info.v') #}
// NABPFilteredRAMSwapControl
//     5 Feb 2012
// Controls the swapping between filtered RAM swappables

{#
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec
    data_len = conf()['kDataLength']
    a_len = conf()['kAngleLength']
    s_val_len = bin_width_of_dec(conf()['projection_line_size'])

    swap_list = range(2)
#}

`define kAngleLength {# a_len #}
`define kSLength {# s_val_len #}
`define kDataLength {# data_len #}

module NABPFilteredRAMSwapControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from host
    input wire unsigned [`kAngleLength-1:0] hs_angle,
    input wire unsigned [`kAngleLength-1:0] hs_next_angle,
    input wire [`kDataLength-1:0] hs_val,
    input wire hs_get_next_angle_ack,
    // inputs from processing swappables
    input wire signed [`kSLength-1:0] fr0_s_val,
    input wire signed [`kSLength-1:0] fr1_s_val,
    // outputs to host
    output wire [`kSLength-1:0] hs_s_val,
    output wire hs_get_next_angle,
    // outputs to processing swappables
    input wire signed [`kFilteredDataLength-1:0] fr0_val,
    input wire signed [`kFilteredDataLength-1:0] fr1_val
);

// TODO implementation

endmodule
