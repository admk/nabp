{# include('nabp_info.v') #}
// NABPShifter
//     {# name() #}
//     31 Dec 2011
// Controls NABPFilterMapper by providing fm_shift_enable
{#
    from pynabp.nabp_config import nabp_config
    from pynabp.nabp_enums import shifter_states
    from pynabp.nabp_utils import bin_width_of_dec, dec_repr
    from pynabp.fixed_point_arith import FixedPoint
#}
`define kAngleLength {# nabp_config()['kAngleLength'] #}

module NABPShifter
(
    // inputs from state_control
    input wire [`kAngleLength-1:0] sc_angle,
    input wire sc_fill_kick,
    input wire sc_shift_kick,
    // outputs to state_control
    output wire sc_fill_done,
    output wire sc_shift_done,
    // outputs to filter mapper
    output reg fm_shift_enable
);
{#
    fill_cnt_init = nabp_config()['partition_scheme']['partitions'][-1] + 1
    fill_cnt_width = bin_width_of_dec(fill_cnt_init)

    shift_cnt_init = nabp_config()['image_size']
    shift_cnt_width = bin_width_of_dec(shift_cnt_init)

    accu_max = nabp_config()['image_size']
    accu_int_width = bin_width_of_dec(accu_max)
    accu_frac_width = 3
    accu_fixed = FixedPoint(accu_int_width, accu_frac_width, value=0)

    accu_base_int_width = 1
    accu_base_frac_width = 3
    accu_base_fixed = FixedPoint(
            accu_base_int_width, accu_base_frac_width, value=0)
#}
reg unsigned [{# fill_cnt_width - 1 #}:0] fill_cnt;
reg unsigned [{# shift_cnt_width - 1 #}:0] shift_cnt;
reg {# accu_fixed.verilog_decl() #} accu;
reg {# accu_base_fixed.verilog_decl() #} accu_base;

always @(posedge clk)
begin:counters
    if (state == fill_s and fill_cnt != 0)
        fill_cnt <= fill_cnt - 1;
    else
        fill_cnt <= {# dec_repr(fill_cnt_init) #};
    if (state == shift_s and shift_cnt != 0)
        shift_cnt <= shift_cnt - 1;
    else
        shift_cnt <= {# dec_repr(shift_cnt_init) #};
    if (state == shift_s)
        accu <= accu + accu_base;
    else
    begin
        accu <= 0'b{# accu_fixed.bin_repr_of_value(0) #};
        accu_base <= // TODO lookup table for accu_base
    end
end

{# include('templates/state_decl(states).v', states=shifter_states) #}

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

// mealy outputs
assign sc_fill_done  = (fill_cnt == 0) and (state == shift_s);
assign sc_shift_done = (shift_cnt == 0);

always @(sc_fill_kick or sc_shift_kick or sc_fill_done or sc_shift_done or
         state)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (sc_fill_kick)
                next_state <= fill_s;
        end
        fill_s:
            if (sc_fill_done)
                next_state <= fill_done_s;
        end
        fill_done_s:
            if (sc_shift_kick)
                next_state <= shift_s;
        end
        shift_s:
            if (sc_shift_done)
                next_state <= ready_s;
        end
    endcase
end

always @(state)
begin:fm_shift_enable
    fm_shift_enable <= 0;
    if (state == fill_s)
        fm_shift_enable <= 1;
    if (state == shift_s)
    begin
        // TODO shift enable signal on shift mode
    end
end

endmodule
