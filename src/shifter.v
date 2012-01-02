{# include('nabp_info.v') #}
// NABPShifter
//     {# name() #}
//     31 Dec 2011
// Controls NABPFilterMapper by providing fm_shift_enable
{#
from pynabp.nabp_config import nabp_config
from pynabp.nabp_enums import shifter_states
from pynabp.nabp_utils import bin_width_of_dec, dec_repr
#}

module NABPShifter
(
    // inputs from state_control
    input wire sc_fill_kick,
    input wire sc_shift_kick,
    // outputs to state_control
    output wire sc_fill_done,
    output wire sc_shift_done,
    // outputs to filter mapper
    output reg fm_shift_enable
);

{#
    fill_count_init = nabp_config()['partition_scheme']['partitions'][-1] + 1
    fill_count_width = bin_width_of_dec(fill_count_init)
    shift_count_init = nabp_config()['image_size']
    shift_count_width = bin_width_of_dec(shift_count_init)
#}
reg unsigned [{# fill_count_width - 1 #}:0] fill_count;
reg unsigned [{# shift_count_width - 1 #}:0] shift_count;

always @(posedge clk)
begin:counters
    if (state == fill_s and fill_count != 0)
        fill_count <= fill_count - 1;
    else
        fill_count <= {# dec_repr(fill_count_init) #};
    if (state == shift_s and shift_count != 0)
        shift_count <= shift_count - 1;
    else
        shift_count <= {# dec_repr(shift_count_init) #};
end

{# include('templates/state_decl(states).v', states=shifter_states) #}

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

// mealy outputs
assign sc_fill_done  = (fill_count == 0) and (state == shift_s);
assign sc_shift_done = (shift_count == 0);

always @(sc_fill_kick or sc_shift_kick or sc_fill_done or sc_shift_done or
         state)
begin:mealy_next_state
    next_state <= state;
    case (state)
        ready_s:
            if (sc_fill_kick)
                next_state <= fill_s;
        end
        fill_s:
            if (sc_fill_done)
                next_state <= fill_done_s;
        end
        fill_done_s:
            if (sc_shift_kick)
                next_state <= shift_s;
        end
        shift_s:
            if (sc_shift_done)
                next_state <= ready_s;
        end
    endcase
end

always @(state)
begin:fm_shift_enable
    fm_shift_enable <= 0;
    if (state == fill_s)
        fm_shift_enable <= 1;
    if (state == shift_s)
    begin
        // TODO shift enable signal on shift mode
    end
end

endmodule
