{# include('templates/info.v') #}
// NABPShifterLUT
//     1 Jan 2012
// Provides NABPShifter the look-up values of $\tan\theta$ and $\cot\theta$
// TODO reduce look-up table size by using symmetry
{#
    from pynabp.utils import xfrange, dec_repr
    from pynabp.conf import conf
    from pynabp.fixed_point_arith import FixedPoint
    from math import tan, radians

    a_len = conf()['kAngleLength']
    accu_fixed = conf()['tShiftAccuBase']
    lookup = conf()['lutShiftAccuBaseFunc']
#}
`define kAngleLength {# a_len #}

module NABPShiferLUT
(
    input wire clk,
    input wire [`kAngleLength-1:0] sh_angle,
    output reg {# accu_fixed.verilog_decl() #} sh_accu_base
);

always @(posedge clk)
begin
    {# set_eat_blanklines(True) #}
    case (sh_angle)
        {% for angle in xfrange(0, 180, conf()['projection_angle_step']) %}
        {# dec_repr(angle, a_len) #}:
            sh_accu_base <= {# lookup(angle) #};
        {% end %}
    endcase
    {# set_eat_blanklines(False) #}
end

endmodule
