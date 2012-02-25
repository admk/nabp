{#
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec
#}
`ifndef kAngleLength
    `define kAngleLength {# conf()['kAngleLength'] #}
`endif
`ifndef kSLength
    `define kSLength {# bin_width_of_dec(conf()['projection_line_size']) #}
`endif
`ifndef kFilteredDataLength
    `define kFilteredDataLength {# conf()['kFilteredDataLength'] #}
`endif

function signed [`kFilteredDataLength-1:0] data_test_vals;
    input [`kSLength-1:0] s;
    input [`kAngleLength-1:0] a;
    begin
        // a simple function to generate a hash value
        data_test_vals = s + a;
    end
endfunction
