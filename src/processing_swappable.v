{# include('templates/defines.v') #}
// NABPProcessingSwappable
//     9 Jan 2012
// The top level entity for data processing modules that are to be swapped
// together

module NABPProcessingSwappable
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from swap control
    input wire {# c['tShiftAccuBase'].verilog_decl() #} sw_sh_accu_base,
    {% for j, k in divisions() %}
    input wire {# c['tMapAccuInit'].verilog_decl() #}
                sw_mp_line{#j#}_seg{#k#}_accu_init,
    {% end %}
    input wire {# c['tMapAccuBase'].verilog_decl() #} sw_mp_accu_base,
    input wire sw_swap_ack,
    input wire sw_next_itr_ack,
    // input from Filtered RAM
    {% for j, k in divisions() %}
    input wire signed [`kFilteredDataLength-1:0] fr_line{#j#}_seg{#k#}_val,
    {% end %}
    // outputs to swap control
    output wire sw_swap,
    output wire sw_next_itr,
    output wire sw_pe_kick
    // output to RAM
    {% for j, k in divisions() %},
    output wire signed [`kSLength-1:0] fr_line{#j#}_seg{#k#}_s_val
    {% end %}
    // output to PEs
    {% for j, k in divisions() %},
    output wire [`kFilteredDataLength*`kNoOfPartitions-1:0]
            pe_line{#j#}_seg{#k#}_taps
    {% end %}
);

wire sh_fill_kick, sh_shift_kick, sh_fill_done, sh_shift_done;
reg {# c['tShiftAccuBase'].verilog_decl() #} sh_accu_base;
reg {# c['tMapAccuBase'].verilog_decl() #} mp_accu_base;

{#
    from pynabp.enums import processing_swappable_states

    include('templates/state_decl(states).v',
            states=processing_swappable_states())
#}

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
    if (state == ready_s)
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
            if (reset_n)
                $display(
                    "<NABPProcessingSwappableStateControl> Invalid state: %d",
                    state);
    endcase
end

wire sh_mp_kick, sh_mp_shift_en, sh_mp_done;
wire sh_lb_clear, sh_lb_shift_en;

NABPShifter shifter
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from state_control
    .sc_fill_kick(sh_fill_kick),
    .sc_shift_kick(sh_shift_kick),
    .sc_accu_base(sh_accu_base),
    // outputs to state_control
    .sc_fill_done(sh_fill_done),
    .sc_shift_done(sh_shift_done),
    // outputs to mapper
    .mp_kick(sh_mp_kick),
    .mp_shift_en(sh_mp_shift_en),
    .mp_done(sh_mp_done),
    // outputs to line buffer
    .lb_clear(sh_lb_clear),
    .lb_shift_en(sh_lb_shift_en),
    // outputs to PEs
    .sw_pe_kick(sw_pe_kick)
);

{% for j, k in divisions() %}
NABPMapper mapper_line{#j#}_seg{#k#}
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from state_control
    .mp_accu_init(sw_mp_line{#j#}_seg{#k#}_accu_init),
    .mp_accu_base(mp_accu_base),
    // inputs from shifter
    .sh_kick(sh_mp_kick),
    .sh_shift_en(sh_mp_shift_en),
    .sh_done(sh_mp_done),
    // outputs to RAM
    .fr_s_val(fr_line{#j#}_seg{#k#}_s_val)
);

line_buffer
#(
    .pNoTaps({# c['partition_scheme']['no_of_partitions'] #}),
    .pTapsWidth({# c['partition_scheme']['size'] #}),
    .pPtrLength({# bin_width(c['partition_scheme']['size']) #}),
    .pDataLength(`kFilteredDataLength)
)
pe_line_buff_line{#j#}_seg{#k#}
(
    .clk(clk),
    .reset_n(reset_n),
    .enable(sh_lb_shift_en),
    .shift_in(fr_line{#j#}_seg{#k#}_val),
    .taps(pe_line{#j#}_seg{#k#}_taps)
);
{% end %}

endmodule
