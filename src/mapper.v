{# include('templates/info.v') #}
// NABPMapper
//     3 Jan 2012
// Provides addresses of the mapped projection line for line buffer

{#
    from pynabp.conf import conf
    from pynabp.enums import mapper_states
    from pynabp.utils import bin_width_of_dec, dec_repr
    from pynabp.fixed_point_arith import FixedPoint

    p_line_size = conf()['projection_line_size']
    s_val_len = bin_width_of_dec(p_line_size)
    accu_fixed = conf()['tMapAccu']
    accu_max = accu_fixed.verilog_repr(p_line_size)
#}
`define kSLength {# s_val_len #}
`define kAngleLength {# conf()['kAngleLength'] #}

module NABPMapper
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from state_control
    input wire {# conf()['tMapAccuInit'].verilog_decl() #} mp_accu_init,
    input wire {# conf()['tMapAccuBase'].verilog_decl() #} mp_accu_base,
    // inputs from shifter
    input wire sh_kick,
    input wire sh_shift_en,
    input wire sh_done,
    // outputs to RAM
    output reg signed [`kSLength-1:0] fr_s_val
);

{# include('templates/state_decl(states).v', states=mapper_states()) #}

reg {# accu_fixed.verilog_decl() #} accu;
wire {# accu_fixed.verilog_decl() #} accu_rounded;
assign accu_rounded = accu + {# accu_fixed.verilog_repr(0.5) #};

always @(*)
begin:fr_s_val_update
    fr_s_val <= 0;
    if ((state != mapping_s) ||
        (accu_rounded < 0 || accu_rounded >= {# accu_max #}))
        fr_s_val <= {# dec_repr(0, s_val_len) #};
    else
        fr_s_val <= accu_rounded {# accu_fixed.verilog_floor_shift() #};
end

always @(posedge clk)
begin:counter
    if (state == ready_s)
        accu <= mp_accu_init;
    else if (state == mapping_s)
        if (sh_shift_en)
            accu <= accu + mp_accu_base;
end

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (sh_kick)
                next_state <= mapping_s;
        mapping_s:
            if (sh_done)
                next_state <= ready_s;
    endcase
end

endmodule
