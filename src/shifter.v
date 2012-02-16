{# include('templates/info.v') #}
// NABPShifter
//     1 Jan 2012
// Controls NABPFilterMapper by providing fm_shift_enable
{#
    from pynabp.conf import conf
    from pynabp.enums import shifter_states
    from pynabp.utils import bin_width_of_dec, dec_repr
    from pynabp.fixed_point_arith import FixedPoint

    fill_cnt_init = conf()['partition_scheme']['partitions'][-1]
    fill_cnt_width = bin_width_of_dec(fill_cnt_init)

    shift_cnt_init = conf()['image_size'] - 1
    shift_cnt_width = bin_width_of_dec(shift_cnt_init)

    accu_fixed = conf()['tShiftAccuBase']
    accu_init_str = accu_fixed.verilog_repr()
    accu_floor_slice = accu_fixed.verilog_floor_slice()
#}
`define kAngleLength {# conf()['kAngleLength'] #}

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
    output reg mp_shift_en,
    output wire mp_done
);

reg [{# fill_cnt_width - 1 #}:0] fill_cnt;
reg [{# shift_cnt_width - 1 #}:0] shift_cnt;
reg {# accu_fixed.verilog_decl() #} accu;
reg {# accu_fixed.verilog_decl() #} accu_prev;

always @(posedge clk)
begin:counters
    mp_shift_en <= 0;

    if (state == fill_s && fill_cnt != {# fill_cnt_width #}'d0)
    begin
        fill_cnt <= fill_cnt - 1;
        mp_shift_en <= 1;
    end
    else
        fill_cnt <= {# dec_repr(fill_cnt_init) #};

    if (state == shift_s && shift_cnt != {# shift_cnt_width #}'d0)
    begin
        shift_cnt <= shift_cnt - 1;
        // it is ok to let it overflow
        // we only need to observe integer boundaries
        accu_prev <= accu;
        accu <= accu + sc_accu_base;
        if (accu{# accu_floor_slice #} ==
                accu_prev{# accu_floor_slice #})
            mp_shift_en <= 0;
        else
            mp_shift_en <= 1;
    end
    else
    begin
        shift_cnt <= {# dec_repr(shift_cnt_init) #};
        accu <= {# accu_init_str #};
        accu_prev <= {# accu_init_str #};
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
assign sc_fill_done  = (fill_cnt == 0) && (state == fill_s);
assign sc_shift_done = (shift_cnt == 0) && (state == shift_s);
assign mp_kick = sc_fill_kick;
assign mp_done = sc_shift_done;

always @(sc_fill_kick or sc_shift_kick or sc_fill_done or sc_shift_done or
         state)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (sc_fill_kick)
                next_state <= fill_s;
        fill_s:
            if (sc_fill_done)
                next_state <= fill_done_s;
        fill_done_s:
            if (sc_shift_kick)
                next_state <= shift_s;
        shift_s:
            if (sc_shift_done)
                next_state <= ready_s;
    endcase
end

endmodule
