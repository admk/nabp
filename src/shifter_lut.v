{# include('templates/info.v') #}
// NABPShifterLUT
//     1 Jan 2012
// Provides NABPShifter the look-up values of
// $\tan\theta$ and $\cot\theta$
{#
    from pynabp.utils import xfrange
    from pynabp.conf import conf
    from pynabp.fixed_point_arith import FixedPoint
    from math import tan, radians

    a_len = conf()['kAngleLength']
    accu_fixed = FixedPoint(1, conf()['kAccuPrecision'])

    def buff_step_val(angle):
        if angle < 0 or angle >= 180:
            raise ValueError('Angle must be within range 0-180')
        if (0 <= angle and angle < 45) or (135 <= angle and angle < 180):
            return abs(tan(radians(angle)))
        else:
            return abs(1 / tan(radians(angle)))
#}
`define kAngleLength {# a_len #}

module NABPShiferLUT
(
    input wire clk,
    input wire [`kAngleLength-1:0] angle,
    output reg {# accu_fixed.verilog_decl() #} sh_accu_base
);

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
