{# include('templates/info.v') #}
// NABPFilteredRAMSwappable
//     6 Feb 2012
// Controls the filling of filtered RAM

{#
    from pynabp.conf import conf
    from pynabp.enums import filtered_ram_control_states
    from pynabp.utils import bin_width_of_dec, dec_repr
    data_len = conf()['kDataLength']
    filtered_data_len = conf()['kFilteredDataLength']
    p_line_size = conf()['projection_line_size']
    s_val_len = bin_width_of_dec(p_line_size)

    def to_s(val):
        return dec_repr(val, s_val_len)
    def to_v(val):
        return dec_repr(val, filtered_data_len)
#}
`define kSLength {# s_val_len #}
`define kDataLength {# data_len #}
`define kFilteredDataLength {# filtered_data_len #}

module NABPFilteredRAMSwappable
(
    // global signals
    input wire clk,
    input wire reset_n,
    // input from host
    input wire hs_fill_kick,
    input wire [`kFilteredDataLength-1:0] hs_val,
    // inputs from processing swappables
    input wire [`kSLength-1:0] pr0_s_val,
    input wire [`kSLength-1:0] pr1_s_val,
    // output to host
    output wire hs_fill_done,
    output wire [`kSLength-1:0] hs_s_val,
    // outputs to processing swappables
    output wire signed [`kFilteredDataLength-1:0] pr0_val,
    output wire signed [`kFilteredDataLength-1:0] pr1_val
);

{#
    include('templates/state_decl(states).v',
            states=filtered_ram_control_states())
#}

// mealy state transition
always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

reg [`kSLength-1:0] write_itr, read_itr;

always @(posedge clk)
begin:itr_update
    if (state == ready_s)
    begin
        read_itr <= {# to_s(0) #};
        write_itr <= {# to_s(0) #};
    end
    else if (state == delay_s)
        read_itr <= read_itr + {# to_s(1) #};
    else if (state == fill_s)
    begin
        write_itr <= write_itr + {# to_s(1) #};
        if (read_itr != {# to_s(p_line_size) #})
            read_itr <= read_itr + {# to_s(1) #};
    end
end

// mealy outputs
wire write_enable;
wire delay_done;
assign hs_fill_done = (next_state == ready_s);
assign hs_s_val = read_itr;
assign write_enable = (state == fill_s);
assign delay_done = (read_itr == {#
        to_s(conf()['filter']['order'] / 2 - 1) #});

// mealy next state
always @(state or hs_fill_kick or delay_done or write_itr)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (hs_fill_kick)
                next_state <= delay_s;
        delay_s:
            if (delay_done)
                next_state <= fill_s;
        fill_s:
            if (write_itr == {# to_s(p_line_size - 1) #})
                next_state <= ready_s;
    endcase
end

wire [`kSLength-1:0] pr0_s_val_m;
assign pr0_s_val_m = (state == ready_s) ? pr0_s_val : write_itr;

NABPDualPortRAM dual_port_ram
(
    .clk(clk),
    .we_0(write_enable),
    .we_1(1'b0),
    .addr_0(pr0_s_val_m),
    .addr_1(pr1_s_val),
    .data_in_0(hs_val),
    .data_in_1({# to_v(0) #}),
    .data_out_0(pr0_val),
    .data_out_1(pr1_val)
);

endmodule
