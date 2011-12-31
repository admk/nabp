// NABPModeControl
// ===============
// Provides operation modes for the NABP architecture
//
// mode_control.v
// Xitong Gao
// 31 Dec 2011


{#
from pynabp.nabp_config import nabp_config
from pynabp.nabp_enums import *
#}

{% for key, val in nabp_config().iteritems() %}
    {% if 'kAngle' in key %}
        `define {# key #} {# val #}
    {% end %}
{% end %}

module NABPModeControl
(
    // input from FSM
    input wire unsigned [`kAngleLength-1:0] angle,
    // outputs
    output wire unsigned [1:0] sector,
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
