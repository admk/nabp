{# include('templates/defines.v') #}
// NABPShifter
//     1 Jan 2012
// Controls NABPFilterMapper by providing fm_shift_enable
{#
    from pynabp.enums import shifter_states

    # fill count varies from the position of the last PE tap to 0
    fill_cnt_init = c['partition_scheme']['partitions'][-1]
    fill_cnt_width = bin_width(fill_cnt_init)

    # shift count varies from the position of the last pixel to 0
    shift_cnt_init = c['image_size'] - 1
    shift_cnt_width = bin_width(shift_cnt_init)

    if shift_cnt_init < fill_cnt_init:
        raise RuntimeError(
                'Fill count (%d) should always be smaller or equal to shift'
                'count (%d).' % (fill_cnt_init, shift_cnt_init))

    accu_fixed = c['tShiftAccuBase']
    accu_init_str = accu_fixed.verilog_repr()
    accu_floor_slice = accu_fixed.verilog_floor_slice()
#}

module NABPShifter
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from state_control
    input wire sc_fill_kick,
    input wire sc_shift_kick,
    input wire {# accu_fixed.verilog_decl() #} sc_accu_base,
    // outputs to state_control
    output wire sc_fill_done,
    output wire sc_shift_done,
    // outputs to mapper
    output wire mp_kick,
    output wire mp_done,
    output wire mp_shift_en,
    // outputs to line buffer
    output wire lb_clear,
    output wire lb_shift_en,
    // outputs to PEs
    output wire sw_pe_en
);

{#
    var_delay_map = {
            'sw_pe_en':      2, # sw_pe_en $\delta$ s_val=>val=>taps
            'lb_shift_en':   1, # lb_shift_en $\delta$ s_val=>val
            'sc_fill_done':  2, # sc_fill_done $\delta$ s_val=>val=>taps->done
            'sc_shift_done': 2, # sc_shift_done $\delta$ s_val=>val=>taps->done
            }
    def var_name(base, delay):
        return base + '_' + str(delay)
#}
// S̲i̲g̲n̲a̲l̲ ̲D̲e̲l̲a̲y̲s̲
// Handled by this module rather than higher level modules
// 2 cycles delay for output control signals to state control
// 1 cycle to get value from the filtered RAM by the specified address;
// 1 cycle to ensure the data is ready at the output of the line buffer.
// Signals being delayed with number of delay cycles are -
//      {# var_delay_map #}.
{% for var, var_delay in var_delay_map.iteritems() %}
    {% for delay in xrange(var_delay + 1) %}
        // declaration
        {% if delay == var_delay %}
            wire {# var #}_l, {# var_name(var, delay) #};
            assign {# var_name(var, delay) #} = {# var #}_l;
        {% else %}
            reg {# var_name(var, delay) #};
        {% end %}
        {% if delay > 0 %}
            always @(posedge clk)
                {# var_name(var, delay - 1) #} <= {# var_name(var, delay) #};
        {% end %}
    {% else %}
        assign {# var #} = {# var_name(var, 0) #};
    {% end %}
{% end %}

// Line buffer - clear on start, simple as that
assign lb_clear = sc_fill_kick;

reg [{# shift_cnt_width - 1 #}:0] cnt;
wire {# accu_fixed.verilog_decl() #} accu_next;
reg {# accu_fixed.verilog_decl() #} accu;

assign accu_next = accu + sc_accu_base;
// it is ok to let it overflow, we only need to observe integer boundaries
assign mp_shift_en = (state == fill_s && next_state == fill_s) ||
                     (state == shift_s &&
                      accu_next{# accu_floor_slice #} !=
                      accu{# accu_floor_slice #});
// lb_shift_en is exactly 2-cycle delayed mp_shift_en
assign lb_shift_en_l = mp_shift_en;

always @(posedge clk)
begin:counters
    if (state == fill_s)
    begin
        if (cnt != {# dec_repr(0, fill_cnt_width) #})
            cnt <= cnt - 1;
        else
            cnt <= {# dec_repr(fill_cnt_init, fill_cnt_width) #};
    end
    else if (state == shift_s)
    begin
        if (cnt != {# dec_repr(0, shift_cnt_width) #})
        begin
            cnt <= cnt - 1;
            accu <= accu_next;
        end
        else
            cnt <= {# dec_repr(shift_cnt_init) #};
    end
    else
    begin
        cnt <= {# dec_repr(fill_cnt_init, fill_cnt_width) #};
        accu <= {# accu_init_str #};
    end
end

{# include('templates/state_decl(states).v', states=shifter_states()) #}

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

// mealy outputs
assign sc_fill_done_l  = (cnt == 0) && (state == fill_s);
assign sc_shift_done_l = (cnt == 0) && (state == shift_s);
assign sw_pe_en_l = (state == shift_s);
assign mp_kick = sc_fill_kick;
assign mp_done = sc_shift_done;

always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (sc_fill_kick)
                next_state <= fill_s;
        fill_s:
            if (sc_fill_done_l)
                next_state <= fill_done_s;
        fill_done_s:
            if (sc_shift_kick)
                next_state <= shift_s;
        shift_s:
            if (sc_shift_done_l)
                next_state <= ready_s;
    endcase
end

endmodule
