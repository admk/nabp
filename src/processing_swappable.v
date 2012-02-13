{# include('templates/info.v') #}
// NABPProcessingSwappable
//     9 Jan 2012
// The top level entity for data processing modules that are to be swapped
// together

{#
    from pynabp.enums import state_control_states
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec

    p_line_size = conf()['projection_line_size']
    s_val_len = bin_width_of_dec(p_line_size)
    data_len = conf()['kFilteredDataLength']
    no_pes = conf()['partition_scheme']['no_of_partitions']
#}
`define kSLength {# s_val_len #}
`define kFilteredDataLength {# data_len #}
`define kNoOfPartitions {# no_pes #}

module NABPProcessingSwappable
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
    // input from Filtered RAM
    input wire signed [`kFilteredDataLength-1:0] fr_val,
    // outputs to swap control
    output wire sw_swap,
    output wire sw_next_itr,
    output wire sw_pe_en,
    // output to RAM
    output wire signed [`kSLength-1:0] fr_s_val,
    // output to PEs
    output wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps
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
    .sw_sh_accu_base(sw_sh_accu_base),
    .sw_mp_accu_init(sw_mp_accu_init),
    .sw_mp_accu_base(sw_mp_accu_base),
    .sw_swap_ack(sw_swap_ack),
    .sw_next_itr_ack(sw_next_itr_ack),
    .sw_pe_en(sw_pe_en),
    // inputs from shifter
    .sh_fill_done(sh_sc_fill_done),
    .sh_shift_done(sh_sc_shift_done),
    // outputs to swap control
    .sw_swap(sw_swap),
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
    .mp_done(sh_mp_done)
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
    .fr_s_val(fr_s_val)
);

reg signed [`kFilteredDataLength-1:0] pe_tap0;
always @(posedge clk)
    pe_tap0 <= fr_val;

assign pe_taps = {
        {% for i in xrange(no_pes) %}
            pe_tap{#i#}{% if i < no_pes - 1 %},{% end %}
        {% end %}
        };

{% if conf()['debug'] %}
{# delay_len = conf()['partition_scheme']['size'] #}
{% for i in xrange(no_pes - 1) %}
wire [`kFilteredDataLength-1:0] pe_tap{#i+1#};

shift_register
#(
    .pDelayLength({# delay_len #}),
    .pPtrLength({# bin_width_of_dec(delay_len) #}),
    .pDataLength(`kFilteredDataLength)
)
sr{#i#}
(
    .clk(clk),
    .enable(sh_mp_shift_en),
    .clear(sw_next_itr),
    .val_in(pe_tap{#i#}),
    .val_out(pe_tap{#i+1#})
);
{% end %}
{% else %}
altshift_taps
#(
    .intended_device_family("{# conf()['device'] #}"),
    .number_of_taps(`kNoOfPartitions - 1),
    .power_up_state("CLEARED"),
    .taps_distance({# conf()['partition_scheme']['size'] #}),
    .width(`kFilteredDataLength),
    .lpm_type("altshift_taps"),
    .lpm_hint("unused")
)
line_buff
(
    // FIXME aclr too early?
    .aclr(sw_next_itr),
    .clken(sh_mp_shift_en),
    .clock(clk),
    .shiftin(pe_tap0),
    .taps(pe_shift_taps)
);
{% end %}

endmodule
