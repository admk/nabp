{# include('templates/info.v') #}
// NABPStateControl
//     31 Dec 2011
// Hold system states for the NABP architecture for the swappable modules
// Coordinate the shifter and mapper modules
{#
    from pynabp.enums import state_control_states
    from pynabp.conf import conf
#}

module NABPStateControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from swap control
    input wire {# conf()['tShiftAccuBase'].verilog_decl() #} sw_sh_accu_base,
    input wire {# conf()['tMapAccuInit'].verilog_decl() #} sw_mp_accu_init,
    input wire {# conf()['tMapAccuBase'].verilog_decl() #} sw_mp_accu_base,
    input wire sw_swap_ack,
    input wire sw_next_itr_ack,
    // inputs from shifter
    input wire sh_fill_done,
    input wire sh_shift_done,
    // output to swap control
    output wire sw_swap,
    output wire sw_next_itr,
    output wire sw_pe_en,
    // output to shifter
    output wire sh_fill_kick,
    output wire sh_shift_kick,
    output reg {# conf()['tShiftAccuBase'].verilog_decl() #} sh_accu_base,
    // output to mapper
    output reg {# conf()['tMapAccuInit'].verilog_decl() #} mp_accu_init,
    output reg {# conf()['tMapAccuBase'].verilog_decl() #} mp_accu_base
);

{# include('templates/state_decl(states).v', states=state_control_states()) #}

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
    begin
        if (state == ready_s)
        begin
            mp_accu_init <= sw_mp_accu_init;
            mp_accu_base <= sw_mp_accu_base;
            sh_accu_base <= sw_sh_accu_base;
        end
        state <= next_state;
    end
end

// mealy outputs
assign sw_swap       = (state == fill_done_s);
assign sw_next_itr   = (state == ready_s);
assign sw_pe_en      = (state == shift_s);
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
                "<NABPStateControl> Invalid state encountered: %d", state);
    endcase
end

endmodule
