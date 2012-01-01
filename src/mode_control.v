{# include('nabp_info.v') #}
// NABPModeControl
//     {# name() #}
//     31 Dec 2011
// Provides operation modes for the NABP architecture
{#
from pynabp.nabp_config import nabp_config
from pynabp.nabp_enums import *
angle_defines = dict(
        (k, v) for k, v in nabp_config().iteritems() if 'kAngle' in k)
set_eat_blanklines(True) #}
{% for key, val in angle_defines.iteritems() %}
`define {# key #} {# val #}
{% end %}
{# set_eat_blanklines(False) #}

module NABPModeControl
(
    // input from FSM
    input wire unsigned [`kAngleLength-1:0] angle,
    // outputs
    output wire [1:0] sector,
    output wire scan_mode,
    output wire scan_direction,
    output wire buff_step_mode,
    output wire buff_step_direction,
);

assign sector =
        (angle < `kAngle90) ?
            ((angle < `kAngle45) ? {# sector.a #} : {# sector.b #}) :
            ((angle < `kAngle135) ? {# sector.c #} : {# sector.d #});
assign scan_mode =
        (sector == {# sector.a #} or sector == {# sector.d #}) ?
        {# scan_mode.x #} : {# scan_mode.y #};
assign scan_direction =
        (sector == {# sector.a #} or sector == {# sector.b #}) ?
        {# scan_direction.forward #} : {# scan_direction.backward #};
assign buff_step_mode =
        (sector == {# sector.a #} or sector == {# sector.d #}) ?
        {# buff_step_mode.tan #} : {# buff_step_mode.cot #};
assign buff_step_direction =
        (sector == {# sector.a #}) ?
        {# buff_step_direction.ascending #} :
        {# buff_step_direction.descending #};
        
endmodule
