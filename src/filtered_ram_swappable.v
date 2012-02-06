{# include('templates/info.v') #}
// NABPFilteredRAMSwappable
//     5 Feb 2012
// The RAM that stores the filtered projection data

{#
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec

    p_line_size = conf()['projection_line_size']
    s_val_len = bin_width_of_dec(p_line_size)
    data_len = conf()['kDataLength']

    port_list = range(2)
#}
`define kSLength {# s_val_len #}
`define kDataLength {# data_len #}
`define kProjectionLineSize {# p_line_size #}

module NABPFilteredRAMSwappable
(
    // global signals
    input wire clk,
    {% for i in port_list %}
    // inputs for port {#i#}
    input wire we_{#i#},
    input wire [`kSLength-1:0] addr_{#i#},
    input wire [`kDataLength-1:0] data_in_{#i#},
    // outputs for port {#i#}
    output wire [`kDataLength-1:0] data_out_{#i#}
    {% if i != port_list[-1] %},{% end %}
    {% end %}
);

reg [`kDataLength-1] ram[`kProjectionLineSize-1:0];

{% for i in port_list %}
always @(posedge clk)
begin:port_{#i#}_read_write
    if (we_{#i#})
    begin
        ram[addr_{#i#}] <= data_in_{#i#};
        data_out_{#i#} <= data_in_{#i#};
    end
    else
        data_out_{#i#} <= ram[addr_{#i#}];
end
{% end %}

endmodule
