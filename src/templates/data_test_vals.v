{#
    from pynabp.conf_gen import config
    from pynabp.utils import bin_width_of_dec
#}
`ifndef kAngleLength
    `define kAngleLength {# config['kAngleLength'] #}
`endif
`ifndef kSLength
    `define kSLength {# bin_width_of_dec(config['projection_line_size']) #}
`endif

function integer data_test_vals;
    input [`kSLength-1:0] s;
    input [`kAngleLength-1:0] a;
    begin
        // a simple function to generate a hash value
        data_test_vals = s + a;
    end
endfunction
