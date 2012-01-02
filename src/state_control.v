{# include('templates/info.v') #}
// NABPStateControl
//     31 Dec 2011
// Provides system states for the NABP architecture
{#
from pynabp.enums import state_control_states
from pynabp.conf import conf
a_len = conf()['kAngleLength']
#}
`define kAngleLength {# a_len #}

module NABPStateControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from swap control
    input wire [`kAngleLength-1:0] sw_angle,
    input wire sw_swap,
    // inputs from shifter
    input wire sh_fill_done,
    input wire sh_shift_done,
    // output the angle this state control holds
    output reg [`kAngleLength-1:0] angle,
    // output to swap control
    output wire sw_swap_ready,
    output wire sw_next_angle,
    // output to shifter
    output wire sh_fill_kick,
    output wire sh_shift_kick
);

{# include('templates/state_decl(states).v', states=state_control_states) #}

always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        angle <= {# a_len #}'d0;
        state <= init_s;
    end
    else
    begin
        if (state == setup_s)
            angle <= sw_angle;
        state <= next_state;
    end
end

// mealy outputs
assign sw_swap_ready = (state == fill_done_s);
assign sw_next_angle = (state == init_s) or
                       (state == shift_done_s);
assign sh_fill_kick  = (next_state != state) and
                       (next_state == fill_s);
assign sh_shift_kick = (next_state != state) and
                       (next_state == shift_s);

// mealy next state
always @(state)
begin:mealy_next_state
    next_state <= state;
    // fsm cases
    case (state) // synopsys parallel_case full_case
        init_s:
            next_state <= setup_s;
        setup_s:
            next_state <= fill_s;
        fill_s:
            if (sh_fill_done)
                next_state <= fill_done_s;
        fill_done_s:
            if (sw_swap)
                next_state <= shift_s;
        shift_s:
            if (sh_shift_done)
                next_state <= shift_done_s;
        shift_done_s:
            next_state <= setup_s;
        default:
            $display(
                "<NABPStateControl> Invalid state encountered: %d", state);
    endcase
end

endmodule
