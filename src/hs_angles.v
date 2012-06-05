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

reg initialised;
assign hs_has_next_angle = (hs_angle < ({# to_a(180) #} - hs_angle_step));
assign hs_next_angle_ack = hs_has_next_angle && hs_next_angle;

always @(posedge clk)
begin:hs_angle_iterate
    if (!reset_n)
    begin
        hs_angle <= {# to_a(0) #};
        initialised <= 0;
    end
    else
    begin
        if (hs_next_angle && hs_has_next_angle)
        begin
            if (!initialised)
                // do not accumulate first for angle 0
                initialised <= 1;
            else
                hs_angle <= hs_angle + hs_angle_step;
        end
    end
end

endmodule
