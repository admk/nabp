{# include('templates/info.v') #}
// NABPMapper
//     3 Jan 2012
// Provides addresses of the mapped projection line for line buffer
// Outputs available in 2 cycles

{# 
    from pynabp.conf import conf
    from pynabp.enums import mapper_states
    from pynabp.utils import xfrange, dec_repr

    a_len = conf()['kAngleLength']
    accu_part_fixed = conf()['tMapAccuPart']
    accu_base_fixed = conf()['tMapAccuBase']
#}
`define kAngleLength {# a_len #}

module NABPMapperLUT
(
    // global signals
    input wire clk,
    // inputs from mapper
    input wire unsigned [`kAngleLength-1:0] mp_angle,
    // outputs to mapper
    output reg {# accu_part_fixed.verilog_decl() #} mp_accu_const_part,
    output reg {# accu_base_fixed.verilog_decl() #} mp_accu_base
);

always @(posedge clk)
begin
    {# set_eat_blanklines(True) #}
    case (mp_angle)
        {% for idx, angle in enumerate(
                xfrange(0, 180, conf()['projection_angle_step'])) %}
        {# dec_repr(angle, a_len) #}:
            {#
                accu_part_val = conf()['lutMapAccuPart'][idx]
                accu_base_val = conf()['lutMapAccuBase'][idx]
            #}
            // {# accu_part_val #}
            mp_accu_const_part <= {#
                    accu_part_fixed.verilog_repr(accu_part_val) #};
            // {# accu_base_val #}
            mp_accu_base <= {# accu_base_fixed.verilog_repr(accu_base_val) #};
        {% end %}
    endcase
    {# set_eat_blanklines(False) #}
end

endmodule
