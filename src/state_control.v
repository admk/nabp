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
    pe_width = conf()['partition_scheme']['size']
    pe_width_len = bin_width_of_dec(pe_width)
    line_cnt_fact_fixed = FixedPoint(pe_width, conf()['kSEvalPrecision'], True)
#}
`define kAngleLength {# a_len #}
`define kPEWidthLength {# pe_width_len #}

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
    input wire {# line_cnt_fact_fixed.verilog_decl() #} sw_line_cnt_fact,
    input wire [`kAngleLength-1:0] sw_angle,
    input wire sw_swap,
    // inputs from shifter
    input wire sh_fill_done,
    input wire sh_shift_done,
    // output the iteration data this state control holds
    output reg {# line_cnt_fact_fixed.verilog_decl() #} mp_line_cnt_fact,
    output reg [`kAngleLength-1:0] mp_angle,
    // output to swap control
    output wire sw_swap_ready,
    output wire sw_next_itr,
    // output to shifter
    output wire sh_fill_kick,
    output wire sh_shift_kick
);

{# include('templates/state_decl(states).v', states=state_control_states()) #}

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
        begin
            mp_angle <= sw_angle;
            mp_line_cnt_fact <= sw_line_cnt_fact;
        end
        state <= next_state;
    end
end

// mealy outputs
assign sw_swap_ready = (state == fill_done_s);
assign sw_next_itr   = (state == init_s) or
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
