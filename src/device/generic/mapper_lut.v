{# include('templates/defines.v') #}
// NABPMapper
//     3 Jan 2012
// Provides addresses of the mapped projection line for line buffer
// Outputs available in 2 cycles
// TODO reduce look-up table size by using symmetry

{#
    from math import sin, cos, radians
    from pynabp.enums import mapper_states

    accu_part_fixed = c['tMapAccuPart']
    accu_base_fixed = c['tMapAccuBase']
    line_seg_fixed = c['tMapLineSegDiff']
#}

module NABPMapperLUT
(
    // global signals
    input wire clk,
    // inputs from mapper
    input wire [`kAngleLength-1:0] mp_angle,
    // outputs to mapper
    // mp_accu_part {# str(accu_part_fixed) #}
    {% for j, k in divisions() %}
    output reg {# accu_part_fixed.verilog_decl() #}
            mp_line{#j#}_seg{#k#}_accu_part,
    {% end %}
    // mp_accu_base {# str(accu_base_fixed) #}
    output reg {# accu_base_fixed.verilog_decl() #} mp_accu_base
);

reg {# line_seg_fixed.verilog_decl() #} wsin, wcos;
reg {# accu_part_fixed.verilog_decl() #} mp_accu_part;

always @(mp_angle or wsin or wcos or mp_accu_part)
begin:mp_accu_part_lattice_update
    reg {# accu_part_fixed.verilog_decl() #} diff;
    {% for j, k in divisions() %}
    if (mp_angle < `kAngle45)
        diff = - wsin * {#j#} - wcos * {#k#};
    else if (mp_angle < `kAngle90)
        diff = + wcos * {#j#} + wsin * {#k#};
    else if (mp_angle < `kAngle135)
        diff = - wcos * {#j#} + wsin * {#k#};
    else
        diff = + wsin * {#j#} - wcos * {#k#};
    mp_line{#j#}_seg{#k#}_accu_part <= mp_accu_part + diff;
    {% end %}
end

always @(posedge clk)
begin
    {# set_eat_blanklines(True) #}
    case (mp_angle)
        {% for idx, angle in enumerate(xrange(0, 180)) %}
        {# dec_repr(angle, c['kAngleLength']) #}:
        begin
            {#
                accu_part_val = c['lutMapAccuPart'][idx]
                accu_base_val = c['lutMapAccuBase'][idx]
                angle_rad = radians(angle)
            #}
            // {# accu_part_val #}
            mp_accu_part <= {# accu_part_fixed.verilog_repr(accu_part_val) #};
            // {# accu_base_val #}
            mp_accu_base <= {# accu_base_fixed.verilog_repr(accu_base_val) #};
            wsin <= {# line_seg_fixed.verilog_repr(sin(angle_rad)) #};
            wcos <= {# line_seg_fixed.verilog_repr(cos(angle_rad)) #};
        end
        {% end %}
    endcase
    {# set_eat_blanklines(False) #}
end

endmodule
