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
    // inputs
    input wire buff_ready;
    input wire pe_ready;
    // outputs
    output wire [`kAngleLength-1:0] buff_angle;
    output reg buff_sel;
    output wire fill_kick;
    output wire shift_kick;
);

parameter [{# states.width - 1 #}:0] // synopsys enum code
    {% for idx, key in enumerate(states.enum_keys()) %}
        {# key #} = {# states.enum_dict()[key] #}
        {% if idx < len(states.enum_keys()) - 1 %},{% end %}
    {% end %};
// synopsys state_vector state
reg [{# states.width - 1 #}:0] // synopsys enum code
        state, next_state;

reg unsigned [`kAngleLength-1:0] angle;
assign buff_angle = angle + {# a_len #}'d1;

wire next_iteration;
assign next_iteration = buff_ready and pe_ready;

always @(posedge clk)
begin:fsm_transition
    if (!reset_n)
    begin
        angle <= {# a_len #}'d0;
        state <= {# states.init #};
        buff_sel <= 0;
    end
    else
    begin
        if (next_iteration)
        begin
            angle <= angle + 1;
            // swap buffer
            buff_sel <= not buff_sel;
        end
        // update state
        state <= next_state;
    end
end

always @(buff_ready or pe_ready or state)
begin:fsm_next_state
    // initial values
    fill_kick <= 0;
    shift_kick <= 0;
    next_state <= state;
    // fsm cases
    case (state) // synopsys parallel_case
        {# states.init #}:
            next_state <= {# states.fill #};
            fill_kick <= 1;
        end
        {# states.fill #}:
            if (next_iteration == 1)
            begin
                next_state <= {# states.fill_shift #};
                fill_kick <= 1;
                shift_kick <= 1;
            end
        end
        {# states.fill_shift #}:
            // stops when finish working
            if ((next_iteration == 1) and (angle >= {# a_len #}'d179))
            begin
                next_state <= {# states.stop #};
            end
            else
            begin
                fill_kick <= 1;
                shift_kick <= 1;
            end
        end
        default:
            $display("Invalid state encountered: %d", state);
    endcase
end

endmodule
