{# include('templates/defines.v') #}
// NABPShifter
//     1 Jan 2012
// Controls NABPFilterMapper by providing fm_shift_enable
{#
    from pynabp.enums import shifter_states

    # fill count varies from the position of the last PE tap to 0
    fill_cnt_init = c['partition_scheme']['partitions'][-1]
    fill_cnt_width = bin_width(fill_cnt_init)
    # FIXME has zero length with only 1 PE, not sure if it works correctly with
    # only one PE
    if fill_cnt_width == 0:
        fill_cnt_width = 1

    # shift count varies from 1 to the position of the last pixel
    # pixel 0 is not needed because it is the final pixel given by filling
    shift_cnt_init = c['image_size'] - 2
    shift_cnt_width = bin_width(shift_cnt_init)

    if shift_cnt_init + 1 < fill_cnt_init:
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
    output wire sw_pe_kick
);

// S̲i̲g̲n̲a̲l̲ ̲D̲e̲l̲a̲y̲s̲
// Handled by this module rather than higher level modules
// 2 cycles delay for output control signals to state control
// 1 cycle to get value from the filtered RAM by the specified address;
// 1 cycle to ensure the data is ready at the output of the line buffer.
// T̲i̲m̲i̲n̲g̲ ̲D̲i̲a̲g̲r̲a̲m̲
//
//          clk _| ̅|_| ̅|_| ̅|_| ̅|_| ̅|       _| ̅|_| ̅|_| ̅|_| ̅|_| ̅|_
//
//   shift_kick  ̅\__________________       _____________________
//               ↘
//   shift_done __↓̲__↘̲______________       _________/ ̅ ̅ ̅\_______
//                ↓   ↓                               ↑
//        s_val _̅_̅↓̲̅_̅_̅X_̅↘̲̅_̅X_̅_̅_̅X_̅_̅_̅X_̅_̅       _̅X_̅_̅_̅X_̅_̅_̅_̅_̅↑̲̅_̅_̅_̅_̅_̅_̅_̅_̅_̅
//                ↓     ↘                             ↑
//          val _̅_̅↓̲̅_̅_̅_̅_̅_̅_̅X_̅_̅_̅X_̅_̅_̅X_̅_̅  ...  _̅X_̅_̅_̅X_̅_̅_̅X_̅↑̲̅_̅_̅_̅_̅_̅_̅_̅_̅_̅
//                ↓       ↓↘                          ↑
//  lb_shift_en __↓̲______/̲/̲̅/̲̅↘̲̅/̲̅/̲̅/̲̅/̲̅/̲̅/̲̅/̲̅       /̲̅/̲̅/̲̅/̲̅/̲̅/̲̅/̲̅/̲̅/̲̅\̲_↑̲_________
//                ↓          ↘                        ↑
//      pe_kick _/ ̅ ̅ ̅\________↓̲ ̲ ̲ ̲ ̲ ̲        ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲↑̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲
//                            ↓                       ↑
//      pe_taps _̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅X_̅_̅_̅X_̅_̅       _̅X_̅_̅_̅X_̅_̅_̅X↗̲̅_̅_̅X_̅_̅_̅_̅_̅_̅_̅
//
//  [processing elements]
//
//  pe write_en  ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅        ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅\ ̲ ̲ ̲
//
//  [comments]
//                           |--------------------------| cycles = shift count
//                   |--------------------------|         cycles = shift count
//                   ^ Note the current pe_taps value is intended for the
//                     first scan pixel.
{#
    var_delay_map = {
            # lb_shift_en $\delta$ s_val=>val
            'lb_shift_en':   ('', 1),
            # sc_fill_done $\delta$ s_val=>val=>taps->done
            'sc_fill_done':  ('', 2),
            # sc_shift_done $\delta$ s_val=>val=>taps->done
            'sc_shift_done': ('', 2),
            }
    include('templates/signal_delay(delay_map).v', delay_map=var_delay_map)
#}

// Line buffer - clear on start, simple as that
assign lb_clear = sc_fill_kick;

reg [{# shift_cnt_width - 1 #}:0] cnt;
wire {# accu_fixed.verilog_decl() #} accu_next;
reg {# accu_fixed.verilog_decl() #} accu;

assign accu_next = accu + sc_accu_base;
// it is ok to let it overflow, we only need to observe integer boundaries
assign mp_shift_en = (state == fill_s) || (state == shift_s &&
                      accu_next{# accu_floor_slice #} !=
                      accu{# accu_floor_slice #});
// lb_shift_en is exactly 2-cycle delayed mp_shift_en
assign lb_shift_en_l = mp_shift_en;

always @(posedge clk)
begin:counters
    case (state) // synopsys parallel_case full_case
        fill_s:
            if (cnt != {# dec_repr(0, fill_cnt_width) #})
                cnt <= cnt - 1;
        fill_done_s:
            cnt <= {# dec_repr(shift_cnt_init) #};
        shift_s:
            if (cnt != {# dec_repr(0, shift_cnt_width) #})
            begin
                cnt <= cnt - 1;
                accu <= accu_next;
            end
        default:
        begin
            cnt <= {# dec_repr(fill_cnt_init, fill_cnt_width) #};
            // initialise accu with half of sc_accu_base. this is to deal
            // with aliasing effects caused by the shifting behaviour.
            // this is because shifting should happen when the accumulated
            // value gets across the pixel boundary rather than the next
            // pixel center.
            accu <= sc_accu_base >> 1;
        end
    endcase
end

{# include('templates/state_decl(states).v', states=shifter_states()) #}

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

reg sc_shift_kick_d;
always @(posedge clk)
    sc_shift_kick_d <= sc_shift_kick;

// mealy outputs
assign sc_fill_done_l  = (cnt == 0) && (state == fill_s);
assign sc_shift_done_l = (cnt == 0) && (state == shift_s);
assign sw_pe_kick = sc_shift_kick_d;
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
            if (sc_shift_kick_d)
                next_state <= shift_s;
        shift_s:
            if (sc_shift_done_l)
                next_state <= ready_s;
        default:
            if (reset_n)
                $display("<NABPShifter> Invalid state: %d", state);
    endcase
end

endmodule
