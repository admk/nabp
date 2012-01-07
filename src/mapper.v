{# include('templates/info.v') #}
// NABPMapper
//     3 Jan 2012
// Provides addresses of the mapped projection line for line buffer

{# 
    from pynabp.conf import conf
    from pynabp.enums import mapper_states
    from pynabp.utils import bin_width_of_dec
    from pynabp.fixed_point_arith import FixedPoint

    s_val_len = bin_width_of_dec(conf()['projection_line_size'])
    mp_accu_base_fixed = conf()['tMapAccuBase']
    mp_accu_init_fixed = conf()['tMapAccuInit']
#}
`define kSLength {# s_val_len #}
`define kAngleLength {# conf()['kAngleLength'] #}

module NABPMapper
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from state_control
    input wire unsigned [`kPEWidthLength-1:0] sc_line_cnt,
    input wire {# mp_accu_init_fixed.verilog_decl() #} mp_accu_init,
    input wire {# mp_accu_base_fixed.verilog_decl() #} mp_accu_base,
    // inputs from shifter
    input wire sh_kick,
    input wire sh_shift_enable,
    input wire sh_done,
    // outputs to shifter
    output wire sh_ack,
    // outputs to RAM
    output reg [`kSLength-1:0] rm_s_val
);

{# include('templates/state_decl(states).v', states=mapper_states()) #}

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

// mealy outputs
assign sh_ack = (state == mapping_s);

always @(state or sh_kick)
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
