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

module NABPStateControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs
    // outputs
    output reg buff_sel;
);

reg unsigned [`{# a_len - 1 #}:0] angle;
reg [{# states.no - 1 #}:0] state, next_state;

always @(posedge clk)
begin:fsm_transition
    if (reset_n == 0)
    begin
        angle <= {# a_len #}'d0;
        state <= {# states.init #};
        buff_sel <= 0;
    end
    else
    begin
        if (next_state != state)
        begin
            // stops when finish working
            if (angle == {# a_len #}'d179)
            begin
                state <= {# states.stop #};
            end
            angle <= angle + 1;
            // swap buffer
            buff_sel <= not buff_sel;
        end
        // update state
        state <= next_state;
    end
end

always @(*)
begin:fsm_next_state
    
end

endmodule
