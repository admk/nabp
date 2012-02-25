{# include('templates/info.v') #}
// hs_angles
//     25 Feb 2012
// This module generates angles for testing
{#
    from pynabp.conf import conf
    from pynabp.utils import dec_repr

    a_len = conf()['kAngleLength']

    def to_a(val):
        return dec_repr(val, a_len)
#}
`define kAngleLength {# a_len #}

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

assign hs_has_next_angle = (hs_angle < {# to_a(80) #});
assign hs_next_angle_ack = hs_has_next_angle && hs_next_angle;

initial
begin:hs_angle_iterate
    hs_angle = {# to_a(0) #};
    @(posedge reset_n);
    while (hs_has_next_angle)
    begin
        @(negedge hs_next_angle_ack or reset_n);
        if (!reset_n)
        begin
            @(posedge clk);
            hs_angle = {# to_a(0) #};
        end
        else
        begin
            if (hs_has_next_angle)
                hs_angle = hs_angle + {# to_a(20) #};
            else
                hs_angle = `kAngleLength'dx;
        end
    end
end

endmodule
