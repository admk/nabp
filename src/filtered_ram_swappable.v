{# include('templates/defines.v') #}
// NABPFilteredRAMSwappable
//     6 Feb 2012
// Controls the filling of filtered RAM

{#
    from pynabp.enums import filtered_ram_control_states
    p_line_size = c['projection_line_size']
#}

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
    else if (state == fill_s && next_state != ready_s)
    begin
        write_itr <= write_itr + {# to_s(1) #};
        if (read_itr != {# to_s(p_line_size - 1) #})
            read_itr <= read_itr + {# to_s(1) #};
    end
end

// mealy outputs
wire write_enable;
wire delay_done;
assign hs_fill_done = (next_state == ready_s);
assign hs_s_val = read_itr;
assign write_enable = (state == fill_s);
// One cycle delay and one cycle advance, one because of synchronous read one
// cycle delay never taken into account, the other one because of something I
// can no longer recall (probably filter requires only
// fir_order / 2 - 1 registers).
assign delay_done = (read_itr == {# to_s(c['fir_order'] / 2) #});

// mealy next state
always @(*)
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
        default:
            if (reset_n)
                $display("<NABPFilterdRAMSwappable> Invalid state: %d", state);
    endcase
end

wire [`kSLength-1:0] pr0_s_val_m;
assign pr0_s_val_m = (state == ready_s) ? pr0_s_val : write_itr;

NABPDualPortRAM dual_port_ram
(
    // globals
    .clk(clk),
    .clear(0), // no need to clear, always overwritten
    // write enables
    .we_0(write_enable),
    .we_1(1'b0),
    // addresses
    .addr_0(pr0_s_val_m),
    .addr_1(pr1_s_val),
    // data
    .data_in_0(hs_val),
    .data_in_1({# to_v(0) #}),
    .data_out_0(pr0_val),
    .data_out_1(pr1_val)
);

endmodule
