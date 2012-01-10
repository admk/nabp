{# include('templates/info.v') #}
// NABPSwappable
//     9 Jan 2011
// The top level entity for modules that are to be swapped together

{#
    from pynabp.enums import state_control_states
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec

    p_line_size = conf()['projection_line_size']
    s_val_len = bin_width_of_dec(p_line_size)
    data_len = conf()['kDataLength']
    a_len = conf()['kAngleLength']
#}
`define kSLength {# s_val_len #}
`define kDataLength {# data_len #}
`define kAngleLength {# a_len #}

module NABPSwappable
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from swap control
    input wire [`kAngleLength-1:0] sw_angle,
    input wire {# conf()['tShiftAccuBase'].verilog_decl() #} sw_sh_accu_base,
    input wire {# conf()['tMapAccuInit'].verilog_decl() #} sw_mp_accu_init,
    input wire {# conf()['tMapAccuBase'].verilog_decl() #} sw_mp_accu_base,
    input wire sw_swap,
    input wire sw_next_itr_ack,
    // input from RAM
    input wire signed [`kDataLength-1:0] rm_val,
    // outputs to swap control
    output wire sw_swap_ready,
    output wire sw_next_itr,
    // output to RAM
    output wire signed [`kSLength-1:0] rm_s_val,
    output wire rm_en
);

wire sc_sh_fill_kick;
wire sc_sh_shift_kick;
wire {# conf()['tShiftAccuBase'].verilog_decl() #} sc_sh_accu_base;
wire sh_sc_fill_done;
wire sh_sc_shift_done;
wire {# conf()['tMapAccuInit'].verilog_decl() #} sc_mp_accu_init;
wire {# conf()['tMapAccuBase'].verilog_decl() #} sc_mp_accu_base;

NABPStateControl state_control
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from swap control
    .sw_angle(sw_angle),
    .sw_sh_accu_base(sw_sh_accu_base),
    .sw_mp_accu_init(sw_mp_accu_init),
    .sw_mp_accu_base(sw_mp_accu_base),
    .sw_swap(sw_swap),
    .sw_next_itr_ack(sw_next_itr_ack),
    // inputs from shifter
    .sh_fill_done(sh_sc_fill_done),
    .sh_shift_done(sh_sc_shift_done),
    // outputs to swap control
    .sw_swap_ready(sw_swap_ready),
    .sw_next_itr(sw_next_itr),
    // outputs to shifter
    .sh_fill_kick(sc_sh_fill_kick),
    .sh_shift_kick(sc_sh_shift_kick),
    .sh_accu_base(sc_sh_accu_base),
    // outputs to mapper
    .mp_accu_init(sc_mp_accu_init),
    .mp_accu_base(sc_mp_accu_base)
);

wire sh_mp_kick;
wire sh_mp_shift_en;
wire sh_mp_done;

NABPShifter shifter
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from state_control
    .sc_fill_kick(sc_sh_fill_kick),
    .sc_shift_kick(sc_sh_shift_kick),
    .sc_accu_base(sc_sh_accu_base),
    // outputs to state_control
    .sc_fill_done(sh_sc_fill_done),
    .sc_shift_done(sh_sc_shift_done),
    // outputs to mapper
    .mp_kick(sh_mp_kick),
    .mp_shift_en(sh_mp_shift_en),
    .mp_done(sh_mp_done),
);

NABPMapper mapper
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from state_control
    .mp_accu_init(sc_mp_accu_init),
    .mp_accu_base(sc_mp_accu_base),
    // inputs from shifter
    .sh_kick(sh_mp_kick),
    .sh_shift_en(sh_mp_shift_en),
    .sh_done(sh_mp_done),
    // outputs to RAM
    .rm_s_val(rm_s_val),
    .rm_en(rm_en)
);

endmodule
