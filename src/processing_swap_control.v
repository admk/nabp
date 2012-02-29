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
);

{#
    include('templates/state_decl(states).v',
            states=processing_swap_control_states())
#}

// line iteration
reg [`kPartitionSizeLength-1:0] line_itr;

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
assign swa_next_itr_ack = (state == setup_s);
// swap_ack to the correct swappable
assign swap_ack = // if wants next angle, then wish to insert angle setup
                  // bubble, swap when setup is done. Both swappable are
                  // guaranteed to be waiting when entering this state
                  (state == angle_setup_s) ||
                  // else if not wanting next angle
                  (!fr_next_angle &&
                   // proceed without delay when swa fill done
                   ((state == fill_s && swa_swap) ||
                   // or swa fill done and swb shift done
                   (state == fill_and_shift_s && swa_swap && swb_next_itr)));
// kick happens when angles are not done yet
assign swb_next_itr_ack = (fr_has_next_angle && swap_ack);
// external
assign fr_next_angle = reset_n && fr_has_next_angle &&
                       (state == ready_s) ||
                       ((state != angle_setup_s) && swb_next_itr &&
                        (line_itr ==
                         {# to_v(c['partition_scheme']['size'] - 1) #}));

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
                next_state <= setup_s;
        setup_s:
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
                    next_state <= angle_setup_s;
            end
        fill_and_shift_s:
            if (swa_swap && swb_next_itr)
            begin
                if (!fr_has_next_angle)
                    next_state <= shift_s;
                else if (fr_next_angle && fr_next_angle_ack)
                    next_state <= angle_setup_s;
            end
        angle_setup_s:
            next_state <= fill_and_shift_s;
        shift_s:
            if (swb_next_itr)
                if (fr_next_angle_ack)
                    next_state <= setup_s;
                else
                    next_state <= ready_s;
        default:
            $display(
                "<NABPProcessingSwapControl> Invalid state encountered: %d",
                state);
    endcase
end

// pe control outputs
reg scan_mode, scan_direction;
assign pe_en = sw_sel ? sw1_pe_en : sw0_pe_en;
assign pe_reset = swa_next_itr_ack;
assign pe_kick = swap_ack;
assign pe_scan_mode = scan_mode;
assign pe_scan_direction = scan_direction;
always @(posedge clk)
begin:pe_setup
    if (state == setup_s)
    begin
        if (fr_angle < `kAngle45 || fr_angle >= `kAngle135)
            scan_mode <= {# scan_mode.x #};
        else
            scan_mode <= {# scan_mode.y #};
        if (fr_angle < `kAngle90)
            scan_direction <= {# scan_direction.forward #};
        else
            scan_direction <= {# scan_direction.reverse #};
    end
end

// lut vals
wire {# c['tShiftAccuBase'].verilog_decl() #} sh_accu_base;
reg {# c['tMapAccuInit'].verilog_decl() #} mp_accu_init;
wire {# c['tMapAccuBase'].verilog_decl() #} mp_accu_base;
wire {# c['tMapAccuPart'].verilog_decl() #} mp_accu_part;

always @(posedge clk)
begin:line_itr_update
    if (state == ready_s)
        line_itr <= {# to_v(0) #};
    else if (swap_ack)
    begin
        if (fr_next_angle)
            line_itr <= {# to_v(0) #};
            mp_accu_init <= mp_accu_part;
        else
        begin
            line_itr <= line_itr + {# to_v(1) #};
            mp_accu_init <= mp_accu_init - mp_accu_base;
        end
    end
end

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

// PE taps values
assign pe_taps = sw_sel ? sw0_pe_taps : sw1_pe_taps;

endmodule
