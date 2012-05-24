{# include('templates/defines.v') #}
// NABPImageAddresser
//     22 May 2012
// The image address generator for values streaming from the PE domino chain.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
{#
    from pynabp.enums import image_addresser_states

    no_of_partitions = c['partition_scheme']['no_of_partitions']

    def to_addr(val):
        return dec_repr(val, bin_width(c['image_size'] ** 2))
#}

module NABPImageAddresser
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from Image RAM
    input wire ir_kick,
    input wire ir_enable,
    // outputs to image RAM
    output wire ir_kick_ack,
    output wire [`kImageAddressLength-1:0] ir_addr
)

{#
    include('templates/state_decl(states).v',
            states=image_addresser_states())
#}

wire pe_done, scan_mode, scan_done, line_done;
reg [`kNoOfPartitonsLength-1:0] pe_pos;
reg [`kImageSizeLength-1:0] scan_pos;
reg [`kPartitionSizeLength-1:0] line_pos;

reg [`kImageSizeLength-1:0] ir_base_addr, addr_off_x, addr_off_y;
assign ir_addr = ir_base_addr +
                 ((scan_mode == {# scan_mode.x #}) ? addr_off_x : addr_off_y);
always @(posedge clk)
begin:ir_addr_update
    if (ir_enable)
    begin
        case (state)
            ready_s, delay_s:
                ir_base_addr <= {# to_addr(0) #};
            addressing_x_s:
                if (scan_done && line_done)
                    ir_base_addr <= {# to_addr(0) #};
                else
                    ir_base_addr <= ir_base_addr + {# to_addr(1) #};
            addressing_y_s:
                if (scan_done && line_done)
                    ir_base_addr <= {# to_addr(0) #};
                else if (scan_done)
                    ir_base_addr <= line_pos + {# to_addr(1) #};
                else
                    ir_base_addr <= ir_base_addr +
                            {# to_addr(c['image_size'] #};
        endcase
    end
end

// mealy outputs
assign scan_mode = (state == addressing_y_s) ?
                   {# scan_mode.y #} : {# scan_mode.x #};
assign pe_done = (pe_pos == {# to_p(no_of_partitions - 1) #});
assign scan_done = (scan_pos == {# to_i(c['image_size']) #});
assign line_done = (line_pos == {# to_l(c['partition_scheme']['size']) #});

assign delay_done = (state == delay_s) && pe_done;
assign ir_kick_ack = delay_done;

// delay state duration
always @(posedge clk)
begin:pe_pos_update
    case (state)
        ready_s:
        begin
            pe_pos <= {# to_p(0) #};
            addr_off_x <= {# to_addr(0) #};
            addr_off_y <= {# to_addr(0) #};
            line_pos <= {# to_l(0) #};
            scan_pos <= {# to_i(0) #};
        end
        delay_s:
            if (delay_done)
            begin
                pe_pos <= {# to_p(0) #};
                addr_off_x <= {# to_addr(0) #};
                addr_off_y <= {# to_addr(0) #};
            end
            else
            begin
                pe_pos <= pe_pos + {# to_p(1) #};
            end
        addressing_x_s, addressing_y_s:
            if (ir_enable)
            begin
                // scan_pos update
                if (scan_done)
                    scan_pos <= {# to_i(0) #};
                else
                    scan_pos <= scan_pos + {# to_i(1) #};
                // line_pos update happens on scan_done
                if (scan_done)
                begin
                    if (line_done)
                        line_pos <= {# to_l(0) #};
                    else
                        line_pos <= line_pos + {# to_l(1) #};
                end
                // pe_pos update when scan_done and line_done and finished
                // addressing the y scan direction
                if (scan_done && line_done && state == addressing_y_s)
                begin
                    pe_pos <= pe_pos + {# to_p(1) #};
                    addr_off_x <= addr_off_x +
                            {# to_addr(
                                c['partition_scheme']['size'] *
                                c['image_size']) #};
                    addr_off_y <= addr_off_y +
                            {# to_addr(c['partition_scheme']['size']) #};
                end
            end
    endcase
end
    
// mealy next state
always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (ir_kick)
                next_state <= delay_s;
        delay_s:
            if (delay_done)
                next_state <= addressing_s;
        addressing_x_s:
            if (ir_enable && scan_done && line_done)
                next_state <= addressing_y_s;
        addressing_y_s:
            if (ir_enable && scan_done && line_done)
            begin
                if (pe_done)
                    next_state <= ready_s;
                else
                    next_state <= addressing_x_s;
            end
        default:
            if (reset_n)
                $display("<NABPImageAddresser> Invalid state: %d", state);
    endcase
end

// mealy state transition
always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

endmodule
