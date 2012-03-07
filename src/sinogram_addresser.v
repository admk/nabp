{# include('templates/defines.v') #}
// NABPSinogramAddresser
//     7 Mar 2012
// Provides sinogram addressing for filtered RAM swappable.
// TODO Future rebinning will also be implemented here.
{#
    def to_sg_addr(val):
        return dec_repr(
                val, c['no_of_angles'] * c['projection_line_size'] - 1)
#}

module NABPSinogramAddresser
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from filtered RAM
    input wire [`kSLength-1:0] fr_s_val,
    input wire fr_next_angle,
    // outputs to filtered RAM
    output reg [`kAngleLength-1:0] fr_angle,
    output wire fr_has_next_angle,
    output wire fr_next_angle_ack,
    // outputs to sinogram RAM
    output wire [`kSinogramAddressLength-1:0] sg_addr
);

assign fr_has_next_angle = (fr_angle < ({# to_a(180) #} - `kAngleStep));
assign fr_next_angle_ack = fr_has_next_angle && fr_next_angle;

reg [`kSinogramAddressLength-1:0] sg_base_addr;
assign sg_addr = sg_base_addr + fr_s_val;

always @(posedge clk)
begin:fr_angle_iterate
    if (!reset_n)
    begin
        fr_angle <= {# to_a(0) #};
        sg_base_addr <= {# to_sg_addr(0) #};
    end
    else if (fr_next_angle && fr_has_next_angle)
    begin
        fr_angle <= fr_angle + fr_angle_step;
        sg_base_addr <= sg_base_addr +
                {# to_sg_addr(c['projection_line_size']) #};
    end
end

endmodule
