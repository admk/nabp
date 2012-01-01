{# include('nabp_info.v') #}
// NABPStateControl
//     {# name() #}
//     31 Dec 2011
// Provides system states for the NABP architecture
{#
from pynabp.nabp_state_control import states
from pynabp.nabp_config import nabp_config
a_len = nabp_config()['kAngleLength']
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
    output wire sw_next_angle,
    // output to shifter
    output wire sh_fill_enable,
    output wire sh_shift_enable,
);

parameter [{# states.width - 1 #}:0] // synopsys enum code
    {% for idx, key in enumerate(states.enum_keys()) %}
        {# key #}_s = {# states.enum_dict()[key] #}
        {% if idx < len(states.enum_keys()) - 1 %},{% end %}
    {% end %};
// synopsys state_vector state
reg [{# states.width - 1 #}:0] // synopsys enum code
        state, next_state;

always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        angle <= {# a_len #}'d0;
        state <= {# states.init #};
    end
    else
    begin
        if (state == {# states.setup #})
        begin
            angle <= sw_angle;
        end
        state <= next_state;
    end
end

// mealy outputs
assign sw_next_angle   = (state == {# states.init #}) or
                         (state == {# states.shift_done #});
assign sh_fill_enable  = (state == {# states.fill #});
assign sh_shift_enable = (state == {# states.shift #});

// mealy next state
always @(state)
begin:mealy_next_state
    next_state <= state;
    // fsm cases
    case (state) // synopsys parallel_case full_case
        init_s:
            next_state <= setup_s;
        end
        setup_s:
            next_state <= fill_s;
        end
        fill_s:
            if (sh_fill_done)
            begin
                next_state <= fill_done_s;
            end
        end
        fill_done_s:
            if (sw_swap)
            begin
                next_state <= shift_s;
            end
        end
        shift_s:
            if (sh_shift_done)
            begin
                next_state <= shift_done_s;
            end
        end
        shift_done_s:
            next_state <= setup_s;
        end
        default:
            $display(
                "<NABPStateControl> Invalid state encountered: %d", state);
    endcase
end

endmodule
