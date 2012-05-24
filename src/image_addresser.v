{# include('templates/defines.v') #}
// NABPImageAddresser
//     22 May 2012
// The image address generator for PE domino feed values.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{#
    from pynabp.enums import image_addresser_states

    delay_duration = c['partition_scheme']['no_of_partitions'] - 1
    def to_pe_id(val):
        return dec_repr(
                val, bin_width(delay_duration))
#}

module NABPImageAddresser
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from Image RAM
    input wire ir_kick,
    input wire ir_enable,
    // outputs to image RAM
    output wire [`kImageAddressLength-1:0] ir_addr,
)

{#
    include('templates/state_decl(states).v',
            states=image_addresser_states())
#}

// mealy outputs
wire delay_done, addressing_done;
reg [`kNoOfPartitonsLength-1:0] delay_cnt;
assign delay_done = (delay_cnt == {# to_pe_id(0) #});

// delay state duration
always @(posedge clk)
begin:delay_cnt_update
    case (state)
        ready_s:
            delay_cnt <= {# to_pe_id(delay_duration) #};
        delay_s:
            delay_cnt <= delay_cnt - {# to_pe_id(1) #};
    endcase
end
    
// mealy next state
always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (ir_kick)
                next_state <= delay_s;
        delay_s:
            if (delay_done)
                next_state <= addressing_s;
        addressing_s:
            if (addressing_done)
                next_state <= ready_s;
        default:
            if (reset_n)
                $display("<NABPImageAddresser> Invalid state: %d", state);
    endcase
end

// mealy state transition
always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

endmodule
