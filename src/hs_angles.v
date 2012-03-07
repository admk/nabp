{# include('templates/defines.v') #}
// hs_angles
//     25 Feb 2012
// This module generates angles for testing

module hs_angles
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from host
    input wire hs_next_angle,
    // outputs to host
    output reg [`kAngleLength-1:0] hs_angle,
    output wire hs_next_angle_ack,
    output wire hs_has_next_angle
);

parameter [`kAngleLength-1:0] hs_angle_step = `kAngleStep;

assign hs_has_next_angle = (hs_angle < ({# to_a(180) #} - hs_angle_step));
assign hs_next_angle_ack = hs_has_next_angle && hs_next_angle;

always @(posedge clk)
begin:hs_angle_iterate
    if (!reset_n)
        hs_angle <= {# to_a(0) #};
    else
    begin
        if (hs_next_angle && hs_has_next_angle)
            hs_angle <= hs_angle + hs_angle_step;
    end
end

endmodule
