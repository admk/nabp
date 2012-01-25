{# include('templates/info.v') #}
// NABPSwapControl
//     24 Jan 2012
// Provides control for the swappables
{#
    from pynabp.conf import conf
    from pynabp.enums import swap_control_states
#}
`define kAngleLength {# conf()['kAngleLength'] #}

module NABPSwapControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    input wire na_kick,
    // inputs from swappables
    input wire sc0_swap_ready,
    input wire sc0_next_itr,
    input wire sc0_pe_en,
    input wire sc1_swap_ready,
    input wire sc1_next_itr,
    input wire sc1_pe_en,
    // outputs to swappables
    //   sc_sel - selects swappable
    output reg sc_sel,
    // sw0
    output wire {# conf()['tShiftAccuBase'].verilog_decl() #} sc0_sh_accu_base,
    output wire {# conf()['tMapAccuInit'].verilog_decl() #} sc0_mp_accu_init,
    output wire {# conf()['tMapAccuBase'].verilog_decl() #} sc0_mp_accu_base,
    output wire sc0_swap,
    output wire sc0_next_itr_ack,
    // sw1
    output wire {# conf()['tShiftAccuBase'].verilog_decl() #} sc1_sh_accu_base,
    output wire {# conf()['tMapAccuInit'].verilog_decl() #} sc1_mp_accu_init,
    output wire {# conf()['tMapAccuBase'].verilog_decl() #} sc1_mp_accu_base,
    output wire sc1_swap,
    output wire sc1_next_itr_ack,
    // output to processing elements
    output wire pe_kick,
    output wire pe_en,
    output wire pe_scan_mode
);

{# include('templates/state_decl(states).v', states=swap_control_states()) #}

// TODO RAM Proprocessing
// TODO Angle iterations
// signals: preprocess_done, next_angle

wire sca_swap_ready;
wire scb_next_itr;
assign sca_swap_ready = sc_sel ? sc1_swap_ready : sc0_swap_ready;
assign scb_next_itr = sc_sel ? sc0_next_itr : sc1_next_itr;

wire swap;
assign swap = (state == fill_s and sca_swap_ready) or
              (state == fill_and_shift_s and sca_swap_ready and scb_next_itr);

// mealy outputs
wire sca_next_itr_ack, scb_next_itr_ack;
assign sca_next_itr_ack = (state == preprocess_s and preprocess_done);
assign scb_next_itr_ack = (!next_angle and swap);
assign sc0_next_itr_ack = sc_sel ? scb_next_itr_ack : sca_next_itr_ack;
assign sc1_next_itr_ack = sc_sel ? sca_next_itr_ack : scb_next_itr_ack;
assign sc0_swap = sc_sel ? 0 : swap;
assign sc1_swap = sc_sel ? swap : 0;

always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        state <= ready_s;
        sc_sel <= 0;
    end
    else
    begin
        state <= next_state;
        if (swap)
            sc_sel <= !sc_sel;
    end
end

always @(state)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (na_kick)
                next_state <= preprocess_s;
        preprocess_s:
            if (preprocess_done)
                next_state <= fill_s;
        fill_s:
            if (swap)
                if (next_angle)
                    next_state <= shift_s;
                else
                    next_state <= fill_and_shift_s;
        fill_and_shift_s:
            if (swap and next_angle)
                next_state <= shift_s;
        shift_s:
            if (scb_next_itr)
                next_state <= preprocess_s;
        default:
            $display(
                "<NABPSwapControl> Invalid state encountered: %d", state);
    endcase
end

endmodule
