{# include('templates/info.v') #}
// NABPMapper
//     3 Jan 2012
// Provides addresses of the mapped projection line for line buffer
// Outputs available in 2 cycles

{# 
    from pynabp.conf import conf
    from pynabp.enums import mapper_states
    from pynabp.utils import bin_width_of_dec, xfrange
    from pynabp.fixed_point_arith import FixedPoint
    from math import sin, cos, radians

    s_val_len = bin_width_of_dec(conf()['projection_line_size'])

    last_pe = conf()['partition_scheme']['partitions'][-1]
    i_center = conf()['image_center']
    i_size = conf()['image_size']
#}
{#
    def look_up(angle):
        sin_val = sin(radians(angle))
        cos_val = cos(radians(angle))
        if (0 <= angle and angle < 45):
            val = last_pe * cos_val
        elif (45 <= angle and angle < 90):
            val = - last_pe * sin_val
        elif (90 <= angle and angle < 135):
            val = - last_pe * sin_val + i_size * cos_val
        elif (135 <= angle and angle < 180):
            val = last_pe * cos_val - i_size * sin_val
        else:
            raise RuntimeError('Invalid angle encountered')
        cnst = conf()['image_center'] * sin_val
        cnst -= conf()['image_center'] * cos_val
        cnst += conf()['projection_line_center']
        return val + cnst

    lut_step = conf()['projection_angle_step']
    lut_map = map(look_up, xfrange(0, 180, lut_step))
    lut_max_val = max(lut_map)
    lut_min_val = min(lut_map)
    lut_int_len = bin_width_of_dec(max(lut_max_val, abs(lut_min_val)))
    lut_frac_len = conf()['kSEvalPrecision']
    lut_fixed = FixedPoint(lut_int_len, lut_frac_len, True)

    a_len = conf()['kAngleLength']
#}
`define kAngleLength {# a_len #}

module NABPMapperLUT
(
    // global signals
    input wire clk,
    // inputs from mapper
    input wire unsigned [`kPEWidthLength-1:0] mp_line_cnt,
    input wire unsigned [`kAngleLength-1:0] mp_angle,
    // outputs to mapper
    output reg {# lut_fixed.verilog_decl() #} mp_lut_val
);

always @(posedge clk)
begin
    {# set_eat_blanklines(True) #}
    case (mp_angle)
        {% for idx, angle in enumerate(xfrange(0, 180, lut_step)) %}
            {# a_len #}'d{# int(angle) #}:
            {# lut_fixed.value = lut_map[idx] #}// {# lut_fixed.value #}
            mp_lut_val <= {# lut_fixed.verilog_repr() #};
        {% end %}
    endcase
    {# set_eat_blanklines(False) #}
end

endmodule
