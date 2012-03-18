{# include('templates/defines.v') #}
// NABPSinogramAddresser
//     7 Mar 2012
// Provides sinogram addressing for filtered RAM swappable.
// TODO Future rebinning will also be implemented here.
{#
    from pynabp.enums import sinogram_addresser_states
    def to_sg_addr(val):
        return dec_repr(
                val, c['kNoOfAngles'] * c['projection_line_size'] - 1)
#}

module NABPSinogramAddresser
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from host
    input wire hs_kick,
    // inputs from filtered RAM
    input wire [`kSLength-1:0] fr_s_val,
    input wire fr_next_angle,
    // outputs to host
    output wire hs_done,
    // outputs to filtered RAM
    output reg [`kAngleLength-1:0] fr_angle,
    output wire fr_has_next_angle,
    output wire fr_next_angle_ack,
    // outputs to sinogram RAM
    output wire [`kSinogramAddressLength-1:0] sg_addr
);

parameter [`kAngleLength-1:0] hs_angle_step = `kAngleStep;

{#
    include('templates/state_decl(states).v',
            states=sinogram_addresser_states())
#}

// m̲e̲a̲l̲y̲ ̲o̲u̲t̲p̲u̲t̲s̲
// it is fine the hs_done signal does not wait for processing modules and PEs
// to finish their current iteration - the filtered RAM swappable simply
// stalls and wait for the next_angle signal from the processing swappable.
assign hs_done = (!fr_has_next_angle && fr_next_angle);

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (hs_kick)
                next_state <= work_s;
        work_s:
            if (hs_done)
                next_state <= ready_s;
    endcase
end

assign fr_has_next_angle = (fr_angle < ({# to_a(180) #} - hs_angle_step));
assign fr_next_angle_ack = (state == work_s) &&
                           (fr_has_next_angle && fr_next_angle);

reg [`kSinogramAddressLength-1:0] sg_base_addr;
assign sg_addr = sg_base_addr + fr_s_val;
reg [`kAngleLength-1:0] fr_angle_l;

always @(posedge clk)
begin:fr_angle_iterate
    if (!reset_n || state == ready_s)
    begin
        fr_angle <= {# to_a(0) #};
        fr_angle_l <= {# to_a(0) #};
        sg_base_addr <= {# to_sg_addr(0) #};
    end
    else if (fr_next_angle && fr_has_next_angle)
    begin
        fr_angle <= fr_angle_l;
        fr_angle_l <= fr_angle_l + hs_angle_step;
        sg_base_addr <= sg_base_addr +
                {# to_sg_addr(c['projection_line_size']) #};
        {% if c['debug'] %}
            $display("angle: %d", fr_angle);
        {% end %}
    end
end

endmodule
