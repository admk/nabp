{# include('templates/info.v') #}
// NABPMapper
//     3 Jan 2012
// Provides addresses of the mapped projection line for line buffer
// Outputs available in 2 cycles

{# 
    from pynabp.conf import conf
    from pynabp.enums import mapper_states
    from pynabp.utils import bin_width_of_dec
    from pynabp.fixed_point_arith import FixedPoint

    s_val_len = bin_width_of_dec(conf()['projection_line_size'])
    s_eval_frac_width = conf()['kSEvalPrecision']

    last_pe = conf()['partition_scheme']['partitions'][-1]
    i_center = conf()['image_center']
    s_eval_int_width = bin_width_of_dec(last_pe - image_center)
    s_eval_fixed = FixedPoint(s_eval_int_width, )
#}
`define kSLength {# s_val_len #}
`define kAngleLength {# conf()['kAngleLength'] #}

module NABPMapperLUT
(
    // global signals
    input wire clk,
    // inputs from mapper
    input wire unsigned [`kPEWidthLength-1:0] mp_line_cnt,
    input wire unsigned [`kAngleLength-1:0] mp_angle,
    // outputs to mapper
    output reg unsigned [`kSLength-1:0] mp_s_val
);

reg {# 
always @(posedge clk)
begin
    {# set_eat_blanklines(True) #}
    case (sh_angle)
        {% for angle in xfrange(0, 180, conf()['projection_angle_step']) %}
            {# a_len #}'d{# int(angle) #}:
            {# accu_fixed.value = buff_step_val(angle) #}
            sh_accu_base <= {# accu_fixed.verilog_repr() #};
        {% end %}
    endcase
    {# set_eat_blanklines(False) #}
end

endmodule
