{# include('templates/defines.v') #}
// NABPProcessingSwapControl
//     24 Jan 2012
// Provides control for the swappables
// Handles swapping between the swappable instances
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Swappable Mux & Demux Scheme
// ------------------------------
// inputs                                      outputs
//         /|          _____          |\
// 0 --/--| |-/-[a]-/-| FSM |-/-[a]-/-| |--/-- 0
// 1 --/--| |-/-[b]-/-|_____|-/-[b]-/-| |--/-- 1
//         \|                         |/
//         |                           |
// sw_sel -*---------------------------*
//
// V̲a̲l̲u̲e̲ ̲T̲a̲b̲l̲e̲
//  _______________________
// | ̲s̲w̲_̲s̲e̲l̲ ̲ ̲|̲ ̲0̲ ̲ ̲ ̲ ̲|̲ ̲1̲ ̲ ̲ ̲ ̲|
// | inputs  | 0->a | 0->b |
// | ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲|̲ ̲1̲-̲>̲b̲ ̲|̲ ̲1̲-̲>̲a̲ ̲|
// | outputs | a->0 | a->1 |
// | ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲|̲ ̲b̲-̲>̲1̲ ̲|̲ ̲b̲-̲>̲0̲ ̲|
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
    input wire signed [`kFilteredDataLength-1:0] fr0_val,
    input wire signed [`kFilteredDataLength-1:0] fr1_val,
    // output to processing elements
    output wire pe_reset,
    output wire pe_kick,
    output wire pe_en,
    output wire pe_scan_mode,
    output wire pe_scan_direction,
    output wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps,
    // output to RAM
    output wire fr_next_angle,
    output wire signed [`kSLength-1:0] fr0_s_val,
    output wire signed [`kSLength-1:0] fr1_s_val
    {% if c['debug'] %},
    // debug signals
    output reg [`kAngleLength-1:0] db_angle,
    output reg [`kPartitionSizeLength-1:0] db_line_itr
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
    if (state == setup_1_s || state == setup_2_s || state == setup_3_s ||
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
wire sw0_pe_en, sw1_pe_en;
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
// initial kick to start swapping
assign swa_next_itr_ack = (state == setup_3_s);
// swap_ack to the correct swappable
// immediately swap swappables after swap_ack
assign swap_ack = // if wants next angle, then wish to insert angle setup
                  // bubble, swap when setup is done. Both swappable are
                  // guaranteed to be waiting when entering this state
                  (state == angle_setup_3_s) ||
                  // else if not wanting next angle
                  (!fr_next_angle &&
                   // proceed without delay when swa fill done
                   ((state == fill_s && swa_swap) ||
                   // or swa fill done and swb shift done
                   (state == fill_and_shift_s && swa_swap && swb_next_itr)));
// kicks the other swappable
assign swb_next_itr_ack = // if we want to swap
                          swap_ack &&
                          // and still has pending iterations
                          (fr_has_next_angle || has_next_line_itr);
// external
assign fr_next_angle = // only ask for next angle if has next angle
                       reset_n && fr_has_next_angle &&
                       // either it's ready to start processing from idle
                       ((state == ready_s) ||
                        // or it's not starting a new angle
                        (state != angle_setup_1_s &&
                         state != angle_setup_2_s &&
                         state != angle_setup_3_s &&
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
            if (fr_next_angle_ack)
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
            next_state <= fill_and_shift_s;
        shift_s:
            if (swb_next_itr)
                next_state <= ready_s;
        default:
            $display(
                "<NABPProcessingSwapControl> Invalid state encountered: %d",
                state);
    endcase
end

// delay signals for PEs
wire [`kAngleLength-1:0] fr_angle_d;
wire [`kPartitionSizeLength-1:0] line_cnt_d;
{#
    var_delay_map = {
        'fr_angle_d': ('[`kAngleLength-1:0]', 3),
        'line_cnt_d': ('[`kPartitionSizeLength-1:0]', 2),
    }
    include('templates/signal_delay(delay_map).v', delay_map=var_delay_map)
#}
assign line_cnt_d_l = line_cnt;
assign fr_angle_d_l = fr_angle;
// decode angle and generate pe control outputs
reg [`kAngleLength-1:0] pe_angle;
// PE signals
// multiplexers & demultiplexers - always give the output using pe_taps
reg scan_direction;
assign pe_taps = sw_sel ? sw0_pe_taps : sw1_pe_taps;
assign pe_en = sw_sel ? sw0_pe_en : sw1_pe_en;
assign pe_reset = swa_next_itr_ack;
assign pe_kick = swap_ack;
// decode angle to give PE control signals
assign pe_scan_mode = (pe_angle < `kAngle45 || pe_angle >= `kAngle135) ?
                      {# scan_mode.x #} : {# scan_mode.y #};
assign pe_scan_direction = scan_direction;
always @(posedge clk)
    // updates angle for PE with the current swappable ready for shifting
    if (swap_ack)
    begin
        scan_direction <= mp_accu_init_step_direction;
        pe_angle <= fr_angle_d;
        {% if c['debug'] %}
        db_angle <= fr_angle_d;
        if (mp_accu_init_step_direction == {# scan_direction.forward #})
            db_line_itr <= line_cnt_d;
        else if (mp_accu_init_step_direction == {# scan_direction.reverse #})
            db_line_itr <= {# to_l(c['partition_scheme']['size'] - 1) #} -
                           line_cnt_d;
        {% end %}
    end

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
    .fr_val(fr{#i#}_val),
    // outputs to swap control
    .sw_swap(sw{#i#}_swap),
    .sw_next_itr(sw{#i#}_next_itr),
    .sw_pe_en(sw{#i#}_pe_en),
    // outputs to Filtered RAM
    .fr_s_val(fr{#i#}_s_val),
    // outputs to PEs
    .pe_taps(sw{#i#}_pe_taps)
);
{% end %}

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
