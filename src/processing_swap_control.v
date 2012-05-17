{# include('templates/defines.v') #}
// NABPProcessingSwapControl
//     24 Jan 2012
// Provides control for the swappables
// Handles swapping between the swappable instances
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// S̲w̲a̲p̲p̲a̲b̲l̲e̲ ̲M̲u̲x̲ ̲&̲ ̲D̲e̲m̲u̲x̲ ̲S̲c̲h̲e̲m̲e̲
//
// inputs                                      outputs
//         /|          _____          |\
// 0  ̶ ̶/̶ ̶ ̶| | ̶/̶ ̶[a] ̶/̶ ̶| FSM | ̶/̶ ̶[a] ̶/̶ ̶| | ̶ ̶/̶ ̶ ̶ 0
// 1  ̶ ̶/̶ ̶ ̶| | ̶/̶ ̶[b] ̶/̶ ̶|_____| ̶/̶ ̶[b] ̶/̶ ̶| | ̶ ̶/̶ ̶ ̶ 1
//         \|                         |/
//         |                           |
// sw_sel -*---------------------------*
//
// S̲e̲l̲e̲c̲t̲ ̲R̲o̲u̲t̲i̲n̲g̲ ̲T̲a̲b̲l̲e̲
//  ______________________
// | ̲s̲w̲_̲s̲e̲l̲ ̲|̲ ̲ ̲ ̲ ̲ ̲r̲o̲u̲t̲i̲n̲g̲ ̲|
// |      0 | 0<->a 1<->b |
// | ̲ ̲ ̲ ̲ ̲ ̲1̲ ̲|̲ ̲0̲<̲-̲>̲b̲ ̲1̲<̲-̲>̲a̲ ̲|
//
// S̲w̲a̲p̲p̲a̲b̲l̲e̲ ̲S̲t̲a̲t̲e̲s̲ ̲T̲a̲b̲l̲e̲
//   ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲
// | ̲s̲w̲_̲s̲e̲l̲ ̲|̲ ̲ ̲ ̲ ̲s̲w̲0̲ ̲ ̲ ̲|̲ ̲ ̲ ̲ ̲s̲w̲1̲ ̲ ̲ ̲|
// |    0   |  filling | shifting |
// | ̲ ̲ ̲ ̲1̲ ̲ ̲ ̲|̲ ̲s̲h̲i̲f̲t̲i̲n̲g̲ ̲|̲ ̲ ̲f̲i̲l̲l̲i̲n̲g̲ ̲|
{#
    from pynabp.enums import \
            processing_swap_control_states, scan_mode, scan_direction
#}

module NABPProcessingSwapControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from filtered RAM swap control
    input wire [`kAngleLength-1:0] fr_angle,
    input wire fr_has_next_angle,
    input wire fr_next_angle_ack,
    input wire fr_prev_angle_release_ack,
    input wire signed [`kFilteredDataLength-1:0] fr0_val,
    input wire signed [`kFilteredDataLength-1:0] fr1_val,
    // output to processing elements
    output wire pe_kick,
    output wire pe_scan_mode,
    output wire pe_scan_direction,
    output wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps,
    // output to RAM
    output wire fr_next_angle,
    output wire fr_prev_angle_release,
    output wire signed [`kSLength-1:0] fr0_s_val,
    output wire signed [`kSLength-1:0] fr1_s_val
    {% if c['debug'] %},
    // debug signals
    output wire [`kAngleLength-1:0] db_angle,
    output wire [`kPartitionSizeLength-1:0] db_line_itr
    {% end %}
);

{#
    include('templates/state_decl(states).v',
            states=processing_swap_control_states())
#}

// line iteration
reg [`kPartitionSizeLength-1:0] line_cnt;
wire has_next_line_itr;
assign has_next_line_itr = (line_cnt !=
                            {# to_l(c['partition_scheme']['size'] - 1) #});
always @(posedge clk)
begin:line_itr_update
    if (state == ready_s ||
        state == setup_1_s || state == setup_2_s || state == setup_3_s ||
        state == angle_setup_1_s ||
        state == angle_setup_2_s ||
        state == angle_setup_3_s)
        line_cnt <= {# to_l(0) #};
    else if (swap_ack)
        line_cnt <= line_cnt + {# to_l(1) #};
end

// mapper mp_accu_init ascending or descending
// reverse the line order for reverse scan direction, simplifies PE
wire mp_accu_init_step_direction;
assign mp_accu_init_step_direction = (fr_angle < `kAngle90) ?
                                     {# scan_direction.forward #} :
                                     {# scan_direction.reverse #};
// accumulator value set up
// V̲a̲l̲u̲e̲ ̲T̲i̲m̲i̲n̲g̲ ̲D̲i̲a̲g̲r̲a̲m̲
//
//          clk  ̅ ̅ ̅ ̅ ̅|_____| ̅ ̅ ̅ ̅ ̅|_____| ̅ ̅ ̅ ̅ ̅|_____| ̅ ̅ ̅ ̅ ̅|_____| ̅ ̅ ̅ ̅ ̅|_____
//
//        angle _̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅X_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅
//
//     lut vals _̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅X_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅
//
// mp_accu_init _̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅X_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅
//
//        state  ̲̅r̲̅e̲̅a̲̅d̲̅y̲̅_̲̅s̲̅ ̲̅ ̲̅ ̲̅X ̲̅s̲̅e̲̅t̲̅u̲̅p̲̅_̲̅1̲̅_̲̅s̲̅ ̲̅X ̲̅s̲̅e̲̅t̲̅u̲̅p̲̅_̲̅2̲̅_̲̅s̲̅ ̲̅X ̲̅s̲̅e̲̅t̲̅u̲̅p̲̅_̲̅3̲̅_̲̅s̲̅ ̲̅X ̲̅f̲̅i̲̅l̲̅l̲̅_̲̅s̲̅ ̲̅ ̲̅ ̲̅ ̲̅
//
//   [comments]            ^ angle updated         ^ calculated mp_accu_init
//                                     ^ mp_accu_part value    ^ safe to shift
always @(posedge clk)
begin:accu_setup
    if (state == setup_2_s || state == angle_setup_2_s)
        // value looked up for the angle only becomes available in the 2nd
        // stage, mp_accu_init will be available in the 3rd stage
        mp_accu_init <= mp_accu_part;
    else if (swap_ack)
        // accumulate on swb_next_itr, which is the only swappable that wants
        // new values
        if (mp_accu_init_step_direction == {# scan_direction.forward #})
            mp_accu_init <= mp_accu_init - mp_accu_base;
        else if (mp_accu_init_step_direction == {# scan_direction.reverse #})
            mp_accu_init <= mp_accu_init + mp_accu_base;
end

// inputs from swappables
wire sw0_swap, sw1_swap;
wire sw0_next_itr, sw1_next_itr;
wire sw0_pe_kick, sw1_pe_kick;
// outputs to swappables
//   sw_sel - selects swappable
reg sw_sel;
wire sw0_swap_ack, sw1_swap_ack;
wire sw0_next_itr_ack, sw1_next_itr_ack;

// mealy outputs
// swapping multiplexers & demultiplexers
wire swa_swap;
wire swa_next_itr, swb_next_itr;
wire swa_next_itr_ack, swb_next_itr_ack;
wire swap_ack;
assign swa_swap = sw_sel ? sw1_swap : sw0_swap;
assign swa_next_itr = sw_sel ? sw1_next_itr : sw0_next_itr;
assign swb_next_itr = sw_sel ? sw0_next_itr : sw1_next_itr;
assign sw0_next_itr_ack = sw_sel ? swb_next_itr_ack : swa_next_itr_ack;
assign sw1_next_itr_ack = sw_sel ? swa_next_itr_ack : swb_next_itr_ack;
assign sw0_swap_ack = sw_sel ? 0 : swap_ack;
assign sw1_swap_ack = sw_sel ? swap_ack : 0;
// internal
wire diverged;
assign diverged = (state == diverged_fill_and_shift_s);
// initial kick to start swapping
assign swa_next_itr_ack = (state == setup_3_s);
// swap_ack to the correct swappable
// immediately swap swappables after swap_ack
assign swap_ack = // if wants next angle, then wish to insert angle setup
                  // bubble, swap when setup is done. Both swappable are
                  // guaranteed to be waiting when entering this state
                  (state == angle_setup_3_s) ||
                  (// else if not wanting next angle
                   !fr_next_angle &&
                   (// proceed without delay when swa fill done
                    (state == fill_s && swa_swap) ||
                    // or swa fill done and swb shift done
                    (swa_swap && swb_next_itr &&
                     ((state == fill_and_shift_s) ||
                      (state == diverged_fill_and_shift_s &&
                       // if diverged wait for release ack
                       fr_prev_angle_release_ack)))));
// kicks the other swappable
assign swb_next_itr_ack = // if we want to swap
                          swap_ack &&
                          // and still has pending iterations
                          (fr_has_next_angle || has_next_line_itr);
// external
assign fr_prev_angle_release = // release old angle when ready
                               (reset_n && (state == ready_s)) ||
                               (// or done for diverged data path
                                swa_swap && swb_next_itr &&
                                (state == diverged_fill_and_shift_s));
assign fr_next_angle = // only ask for next angle if has next angle
                       reset_n && fr_has_next_angle &&
                       (// it's not already starting a new angle
                        (state != angle_setup_1_s &&
                         state != angle_setup_2_s &&
                         state != angle_setup_3_s &&
                         // already in diverge path, can't diverge any more
                         state != diverged_fill_and_shift_s &&
                         // and swb is ready to start with a new line and all
                         // lines are being processed for the current angle
                         swb_next_itr && !has_next_line_itr));

always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        state <= ready_s;
        sw_sel <= 0;
    end
    else
    begin
        state <= next_state;
        if (swap_ack)
            sw_sel <= !sw_sel;
    end
end

always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (fr_prev_angle_release_ack)
                next_state <= setup_1_s;
        setup_1_s:
            next_state <= setup_2_s;
        setup_2_s:
            next_state <= setup_3_s;
        setup_3_s:
            if (swa_next_itr)
                next_state <= fill_s;
        fill_s:
            if (swa_swap)
            begin
                if (!fr_has_next_angle)
                    next_state <= shift_s;
                else if (!fr_next_angle)
                    next_state <= fill_and_shift_s;
                else if (fr_next_angle && fr_next_angle_ack)
                    next_state <= angle_setup_1_s;
            end
        fill_and_shift_s:
            if (swa_swap && swb_next_itr)
            begin
                // no more angles, and no more lines to scan besides one last
                // shift!
                if (!fr_has_next_angle && !has_next_line_itr)
                    next_state <= shift_s;
                // wait for next angle
                else if (fr_next_angle_ack)
                    next_state <= angle_setup_1_s;
            end
        angle_setup_1_s:
            next_state <= angle_setup_2_s;
        angle_setup_2_s:
            next_state <= angle_setup_3_s;
        angle_setup_3_s:
            next_state <= diverged_fill_and_shift_s;
        diverged_fill_and_shift_s:
            if (fr_prev_angle_release_ack)
                next_state <= fill_and_shift_s;
        shift_s:
            if (swb_next_itr)
                next_state <= ready_s;
        default:
            if (reset_n)
                $display(
                    "<NABPProcessingSwapControl> Invalid state: %d", state);
    endcase
end

reg [`kAngleLength-1:0] pe_angle;

{% if c['debug'] %}
    // debug signals
    reg [`kPartitionSizeLength-1:0] db_line_cnt;
    wire [`kPartitionSizeLength-1:0] line_cnt_d;

    // line_cnt signal delay for debug
    {#
        include('templates/signal_delay(delay_map).v',
                delay_map={'line_cnt_d': ('[`kPartitionSizeLength-1:0]', 2)})
    #}
    assign line_cnt_d_l = line_cnt;

    always @(posedge clk)
        if (swap_ack)
            db_line_cnt <= line_cnt_d;

    // wiring
    assign db_line_itr = (pe_angle < `kAngle90) ?  db_line_cnt :
                        {# to_l(c['partition_scheme']['size'] - 1) #} -
                        db_line_cnt;
    assign db_angle = pe_angle;
{% end %}

// delay signals for PEs
wire [`kAngleLength-1:0] fr_angle_d;
{#
    var_delay_map = {
        'fr_angle_d': ('[`kAngleLength-1:0]', 3),
    }
    include('templates/signal_delay(delay_map).v', delay_map=var_delay_map)
#}
assign fr_angle_d_l = fr_angle;

// decode angle and generate pe control outputs
always @(posedge clk)
    // updates angle for PE with the current swappable ready for shifting
    if (swap_ack)
        pe_angle <= fr_angle_d;

// PE signals
// multiplexers & demultiplexers - always give the output using pe_taps
assign pe_taps = sw_sel ? sw0_pe_taps : sw1_pe_taps;
assign pe_kick = sw_sel ? sw0_pe_kick : sw1_pe_kick;
// decode angle to give PE control signals
assign pe_scan_mode = (pe_angle < `kAngle45 || pe_angle >= `kAngle135) ?
                      {# scan_mode.x #} : {# scan_mode.y #};
assign pe_scan_direction = (pe_angle < `kAngle90) ?
                           {# scan_direction.forward #} :
                           {# scan_direction.reverse #};

// lut vals
wire {# c['tShiftAccuBase'].verilog_decl() #} sh_accu_base;
reg {# c['tMapAccuInit'].verilog_decl() #} mp_accu_init;
wire {# c['tMapAccuBase'].verilog_decl() #} mp_accu_base;
wire {# c['tMapAccuPart'].verilog_decl() #} mp_accu_part;

{% for i in [0, 1] %}
// swappable {#i#}
wire {# c['tShiftAccuBase'].verilog_decl() #} sw{#i#}_sh_accu_base;
wire {# c['tMapAccuInit'].verilog_decl() #} sw{#i#}_mp_accu_init;
wire {# c['tMapAccuBase'].verilog_decl() #} sw{#i#}_mp_accu_base;
wire [`kSLength-1:0] sw{#i#}_fr_s_val;
wire [`kFilteredDataLength-1:0] sw{#i#}_fr_val;
wire [`kFilteredDataLength*`kNoOfPartitions-1:0] sw{#i#}_pe_taps;
assign sw{#i#}_sh_accu_base = sh_accu_base;
assign sw{#i#}_mp_accu_init = mp_accu_init;
assign sw{#i#}_mp_accu_base = mp_accu_base;
// module instantiation
NABPProcessingSwappable sw{#i#}
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from swap control
    .sw_sh_accu_base(sw{#i#}_sh_accu_base),
    .sw_mp_accu_init(sw{#i#}_mp_accu_init),
    .sw_mp_accu_base(sw{#i#}_mp_accu_base),
    .sw_swap_ack(sw{#i#}_swap_ack),
    .sw_next_itr_ack(sw{#i#}_next_itr_ack),
    // inputs from Filtered RAM
    .fr_val(sw{#i#}_fr_val),
    // outputs to swap control
    .sw_swap(sw{#i#}_swap),
    .sw_next_itr(sw{#i#}_next_itr),
    .sw_pe_kick(sw{#i#}_pe_kick),
    // outputs to Filtered RAM
    .fr_s_val(sw{#i#}_fr_s_val),
    // outputs to PEs
    .pe_taps(sw{#i#}_pe_taps)
);
{% end %}

// F̲i̲l̲t̲e̲r̲e̲d̲ ̲R̲A̲M̲ ̲P̲o̲r̲t̲s̲ ̲<̲-̲>̲ ̲P̲r̲o̲c̲e̲s̲s̲i̲n̲g̲ ̲S̲w̲a̲p̲p̲a̲b̲l̲e̲s̲ ̲R̲o̲u̲t̲i̲n̲g̲ ̲T̲a̲b̲l̲e̲
//   ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲
// | ̲s̲w̲_̲s̲e̲l̲ ̲|̲ ̲d̲i̲v̲e̲r̲g̲e̲d̲ ̲|̲ ̲f̲r̲0̲ ̲|̲ ̲f̲r̲1̲ ̲|
// |      0 |        0 | sw0 | sw1 |
// |      0 |        1 | sw1 | sw0 |
// |      1 |        0 | sw0 | sw1 |
// | ̲ ̲ ̲ ̲ ̲ ̲1̲ ̲|̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲1̲ ̲|̲ ̲s̲w̲0̲ ̲|̲ ̲s̲w̲1̲ ̲|
assign fr0_s_val = (!sw_sel && diverged) ? sw1_fr_s_val : sw0_fr_s_val;
assign fr1_s_val = (!sw_sel && diverged) ? sw0_fr_s_val : sw1_fr_s_val;
assign sw0_fr_val = (!sw_sel && diverged) ? fr1_val : fr0_val;
assign sw1_fr_val = (!sw_sel && diverged) ? fr0_val : fr1_val;

// look-up tables
NABPMapperLUT mapper_lut
(
    // inputs
    .clk(clk),
    .mp_angle(fr_angle),
    // outputs
    .mp_accu_part(mp_accu_part),
    .mp_accu_base(mp_accu_base)
);
NABPShifterLUT shifter_lut
(
    // inputs
    .clk(clk),
    .sh_angle(fr_angle),
    // output
    .sh_accu_base(sh_accu_base)
);

endmodule
