{# include('templates/info.v') #}
// shift_register
//     11 Feb 2012
// A shift register for testing as an FIR filter
{#
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec, dec_repr
    filtered_data_len = conf()['kFilteredDataLength']
    delay = conf()['filter']['order'] / 2
#}
`define kFilteredDataLength {# filtered_data_len #}
`define kDelayLength {# delay #}

module shift_register
(
    clk, reset_n,
    enable, clear,
    val_in, val_out
);

parameter pDelayLength = `kDelayLength;
parameter pDataLength = `kFilteredDataLength;
parameter pDelayDataLength = pDataLength * pDelayLength;

input wire clk, reset_n, enable, clear;
input wire [pDataLength-1:0] val_in;
output wire [pDataLength-1:0] val_out;

reg [pDataLength-1:0] data[pDelayLength-1:0];
assign val_out = data[pDelayDataLength-1];
always @(posedge clk)
begin:shift_reg
    {% for idx in xrange(delay) %}
    if (clear)
        data[{#idx#}] <= {pDataLength{1'b0}};
    else if (enable)
        data[{#idx#}] <=
                {% if idx == 0 %}
                    val_in
                {% else %}
                    data[{# idx - 1 #}]
                {% end %};
    {% end %}
end

endmodule
