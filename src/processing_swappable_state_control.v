{# include('templates/defines.v') #}
// NABPProcessingSwappableStateControl
//     31 Dec 2011
// Hold system states for the NABP architecture for the swappable modules
// Coordinate the shifter and mapper modules
{#
    from pynabp.enums import processing_state_control_states
#}

module NABPProcessingSwappableStateControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from swap control
    input wire {# c['tShiftAccuBase'].verilog_decl() #} sw_sh_accu_base,
    input wire {# c['tMapAccuInit'].verilog_decl() #} sw_mp_accu_init,
    input wire {# c['tMapAccuBase'].verilog_decl() #} sw_mp_accu_base,
    input wire sw_swap_ack,
    input wire sw_next_itr_ack,
    // inputs from shifter
    input wire sh_fill_done,
    input wire sh_shift_done,
    // output to swap control
    output wire sw_swap,
    output wire sw_next_itr,
    // output to shifter
    output wire sh_fill_kick,
    output wire sh_shift_kick,
    output reg {# c['tShiftAccuBase'].verilog_decl() #} sh_accu_base,
    // output to mapper
    output wire {# c['tMapAccuInit'].verilog_decl() #} mp_accu_init,
    output reg {# c['tMapAccuBase'].verilog_decl() #} mp_accu_base
);

{#
    include('templates/state_decl(states).v',
            states=processing_state_control_states())
#}

// mp_accu_init only used once, no need to hold its value
// and eliminate 1 cycle delay by doing this
assign mp_accu_init = sw_mp_accu_init;

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
    if (sw_next_itr)
    begin
        mp_accu_base <= sw_mp_accu_base;
        sh_accu_base <= sw_sh_accu_base;
    end
end

// mealy outputs
assign sw_swap       = (state == fill_done_s);
assign sw_next_itr   = reset_n && (state == ready_s);
assign sh_fill_kick  = (next_state != state) && (next_state == fill_s);
assign sh_shift_kick = (next_state != state) && (next_state == shift_s);

// mealy next state
always @(*)
begin:mealy_next_state
    next_state <= state;
    // fsm cases
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (sw_next_itr_ack)
                next_state <= fill_s;
        fill_s:
            if (sh_fill_done)
                next_state <= fill_done_s;
        fill_done_s:
            if (sw_swap_ack)
                next_state <= shift_s;
        shift_s:
            if (sh_shift_done)
                next_state <= ready_s;
        default:
            $display(
                "<NABPProcessingSwappableStateControl> Invalid state: %d",
                state);
    endcase
end

endmodule
