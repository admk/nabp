{# include('templates/info.v') #}
// NABPStateControl
//     31 Dec 2011
// Provides system states for the NABP architecture
{#
    from pynabp.utils import bin_width_of_dec, dec_repr
    from pynabp.fixed_point_arith import FixedPoint
    from pynabp.enums import state_control_states
    from pynabp.conf import conf

    sh_accu_fixed = conf()['tShiftAccuBase']
    mp_accu_fixed = conf()['tMapAccuBase']

    a_len = conf()['kAngleLength']
#}
`define kAngleLength {# a_len #}

module NABPStateControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from swap control
    //   sw_line_cnt_fact is a pre-calculated value
    // = line_cnt * $\cos\theta$
    //          when $0\leq\theta{<}45$ or $135\leq\theta{<}180$
    // = -line_cnt * $\sin\theta$
    //          when $0\leq\theta{<}135$
    input wire {# conf()['tLineCntFact'].verilog_decl() #} sw_line_cnt_fact,
    input wire {# sh_accu_fixed.verilog_decl() #} sw_sh_accu_base,
    input wire {# mp_accu_fixed.verilog_decl() #} sw_mp_accu_base,
    input wire [`kAngleLength-1:0] sw_angle,
    input wire sw_swap,
    input wire sw_next_itr_ack,
    // inputs from shifter
    input wire sh_fill_done,
    input wire sh_shift_done,
    // output to swap control
    output wire sw_swap_ready,
    output wire sw_next_itr,
    // output to shifter
    output wire sh_fill_kick,
    output wire sh_shift_kick,
    output reg {# sh_accu_fixed.verilog_decl() #} sh_accu_base,
    // output to mapper
    output wire {# conf()['tMapAccuInit'].verilog_decl() #} mp_accu_init,
    output wire {# conf()['tMapAccuBase'].verilog_decl() #} mp_accu_base
);

{# include('templates/state_decl(states).v', states=state_control_states()) #}

reg unsigned [`kAngleLength-1:0] angle;

always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        angle <= {# a_len #}'d0;
        state <= ready_s;
    end
    else
    begin
        if (state == ready_s)
        begin
            angle <= sw_angle;
            mp_line_cnt_fact <= sw_line_cnt_fact;
            mp_accu_base <= sw_mp_accu_base;
            sh_accu_base <= sw_sh_accu_base;
        end
        state <= next_state;
    end
end

// mealy outputs
assign sw_swap_ready = (state == fill_done_s);
assign sw_next_itr   = (state == ready_s);
assign sh_fill_kick  = (next_state != state) and (next_state == fill_s);
assign sh_shift_kick = (next_state != state) and (next_state == shift_s);

// mealy next state
always @(state)
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
