{# include('templates/defines.v') #}
// NABPShifterLUT
//     1 Jan 2012
// Provides NABPShifter the look-up values of $\tan\theta$ and $\cot\theta$
// TODO reduce look-up table size by using symmetry
{#
    from pynabp.utils import xfrange
    from math import tan, radians

    lookup = c['lutShiftAccuBaseFunc']
#}

module NABPShifterLUT
(
    input wire clk,
    input wire [`kAngleLength-1:0] sh_angle,
    output reg {# c['tShiftAccuBase'].verilog_decl() #} sh_accu_base
);

always @(posedge clk)
begin
    {# set_eat_blanklines(True) #}
    case (sh_angle)
        {% for angle in xrange(0, 180) %}
        {# dec_repr(angle, c['kAngleLength']) #}:
            sh_accu_base <= {# lookup(angle) #};
        {% end %}
    endcase
    {# set_eat_blanklines(False) #}
end

endmodule
