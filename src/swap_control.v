{# include('templates/info.v') #}
// NABPSwapControl
//     24 Jan 2012
// Provides control for the swappables
// Handles swapping between the swappable instances
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
    // inputs from host
    input wire unsigned [`kAngleLength-1:0] hs_angle,
    input wire hs_next_angle_ack,
    // outputs to host
    output wire hs_next_angle,
    // output to processing elements
    output wire pe_reset,
    output wire pe_kick,
    output wire pe_en,
    output wire pe_scan_mode
);

{# include('templates/state_decl(states).v', states=swap_control_states()) #}

// inputs from swappables
wire sw0_swap, sw1_swap;
wire sw0_next_itr, sw1_next_itr;
wire sw0_pe_en, sw1_pe_en; // TODO pe_en
// outputs to swappables
//   sw_sel - selects swappable
reg sw_sel;
// TODO lut vals
wire {# conf()['tShiftAccuBase'].verilog_decl() #}
        sw0_sh_accu_base, sw1_sh_accu_base;
wire {# conf()['tMapAccuInit'].verilog_decl() #}
        sw0_mp_accu_init, sw1_mp_accu_init;
wire {# conf()['tMapAccuBase'].verilog_decl() #}
        sw0_mp_accu_base, sw1_mp_accu_base;
wire sw0_swap_ack, sw1_swap_ack;
wire sw0_next_itr_ack, sw1_next_itr_ack;

// mealy outputs
wire swa_swap;
wire swb_next_itr;
wire swa_next_itr_ack, swb_next_itr_ack;
wire swap_ack;
assign swa_swap = sw_sel ? sw1_swap : sw0_swap;
assign swb_next_itr = sw_sel ? sw0_next_itr : sw1_next_itr;
assign swap_ack = (state == fill_s and swa_swap) or
                  (state == fill_and_shift_s and swa_swap and swb_next_itr);
assign swa_next_itr_ack = (state == setup_s and hs_next_angle_ack);
assign swb_next_itr_ack = (!has_next_itr and swap_ack);
assign sw0_next_itr_ack = sw_sel ? swb_next_itr_ack : swa_next_itr_ack;
assign sw1_next_itr_ack = sw_sel ? swa_next_itr_ack : swb_next_itr_ack;
assign sw0_swap_ack = sw_sel ? 0 : swap_ack;
assign sw1_swap_ack = sw_sel ? swap_ack : 0;

always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        state <= ready_s;
        sw_sel <= 0;
    end
    else
    begin
        state <= next_state;
        if (swap_ack)
            sw_sel <= !sw_sel;
    end
end

always @(state)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (hs_next_angle_ack)
                next_state <= fill_s;
        fill_s:
            if (swap_ack)
                if (has_next_itr)
                    next_state <= shift_s;
                else
                    next_state <= fill_and_shift_s;
        fill_and_shift_s:
            if (swap_ack and has_next_itr)
                next_state <= shift_s;
        shift_s:
            if (swb_next_itr)
                next_state <= preprocess_s;
        default:
            $display(
                "<NABPSwapControl> Invalid state encountered: %d", state);
    endcase
end

{% for i in [0, 1] %}
NABPSwappable sw{#i#}
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from swap control
    .sw_sh_accu_base(sw{#i#}_sh_accu_base),
    .sw_mp_accu_init(sw{#i#}_mp_accu_init),
    .sw_mp_accu_base(sw{#i#}_mp_accu_base),
    .sw_swap_ack(sw{#i#}_swap_ack),
    .sw_next_itr_ack(sw{#i#}_next_itr_ack),
    // TODO inputs from Filtered RAM
    .fr_val(),
    // outputs to swap control
    .sw_swap(sw{#i#}_swap),
    .sw_next_itr(sw{#i#}_next_itr),
    .sw_pe_en(sw{#i#}_pe_en),
    // outputs to Filtered RAM
    .fr_s_val(),
    // TODO outputs to PEs
    .pe_taps(),
);
{% end %}

NABPMapperLUT mapper_lut
(
    // inputs
    .clk(clk),
    .mp_line_cnt(),
    .mp_angle(),
    // outputs
    .mp_accu_const_part(),
    .mp_accu_base()
);

NABPShifterLUT shifter_lut
(
    // inputs
    .clk(clk),
    .sh_angle(),
    // output
    .sh_accu_base()
);

endmodule
