{# include('templates/info.v') #}
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
// Value Tabel
// -----------
//  _______________________
// | ̲s̲w̲_̲s̲e̲l̲ ̲ ̲|̲ ̲0̲ ̲ ̲ ̲ ̲|̲ ̲1̲ ̲ ̲ ̲ ̲|
// | inputs  | 0->a | 0->b |
// | ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲|̲ ̲1̲-̲>̲b̲ ̲|̲ ̲1̲-̲>̲a̲ ̲|
// | outputs | a->0 | a->1 |
// | ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲|̲ ̲b̲-̲>̲1̲ ̲|̲ ̲b̲-̲>̲0̲ ̲|
{#
    from pynabp.conf import conf
    from pynabp.enums import swap_control_states, scan_mode, scan_direction
    from pynabp.utils import bin_width_of_dec, dec_repr

    s_val_len = bin_width_of_dec(conf()['projection_line_size'])
    data_len = conf()['kFilteredDataLength']
    partition_size = conf()['partition_scheme']['size']
    partition_size_len = bin_width_of_dec(partition_size)
    no_pes = conf()['partition_scheme']['no_of_partitions']

    angle_defines = dict(
            (k, v) for k, v in conf().iteritems() if 'kAngle' in k)

    def to_v(val):
        return dec_repr(val, partition_size_len)
#}
{% for key, val in angle_defines.iteritems() %}
`define {# key #} {# val #} {% end %}

`define kSLength {# s_val_len #}
`define kFilteredDataLength {# data_len #}
`define kPartitionSizeLength {# partition_size_len #}
`define kNoOfPartitions {# no_pes #}

module NABPProcessingSwapControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from filtered RAM swap control
    input wire [`kAngleLength-1:0] fr_angle,
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

{# include('templates/state_decl(states).v', states=swap_control_states()) #}

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
wire swa_swap;
wire swa_next_itr, swb_next_itr;
wire swa_next_itr_ack, swb_next_itr_ack;
wire swap_ack;
wire has_next_itr;
assign swa_swap = sw_sel ? sw1_swap : sw0_swap;
assign swa_next_itr = sw_sel ? sw1_next_itr : sw0_next_itr;
assign swb_next_itr = sw_sel ? sw0_next_itr : sw1_next_itr;
assign swap_ack = (state == fill_s || state == fill_and_shift_s) &&
                  (swa_swap && swb_next_itr);
assign swa_next_itr_ack = (state == setup_s);
assign swb_next_itr_ack = (has_next_itr && swap_ack);
assign sw0_next_itr_ack = sw_sel ? swb_next_itr_ack : swa_next_itr_ack;
assign sw1_next_itr_ack = sw_sel ? swa_next_itr_ack : swb_next_itr_ack;
assign sw0_swap_ack = sw_sel ? 0 : swap_ack;
assign sw1_swap_ack = sw_sel ? swap_ack : 0;
assign fr_next_angle = state == ready_s ||
                       (state == shift_s && swb_next_itr);
assign has_next_itr = (line_itr != {# to_v(partition_size - 1) #});

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
            if (swap_ack)
                if (!has_next_itr)
                    next_state <= shift_s;
                else
                    next_state <= fill_and_shift_s;
        fill_and_shift_s:
            if (swap_ack && !has_next_itr)
                next_state <= shift_s;
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
wire {# conf()['tShiftAccuBase'].verilog_decl() #} sh_accu_base;
reg {# conf()['tMapAccuInit'].verilog_decl() #} mp_accu_init;
wire {# conf()['tMapAccuBase'].verilog_decl() #} mp_accu_base;
wire {# conf()['tMapAccuPart'].verilog_decl() #} mp_accu_part;

always @(posedge clk)
begin:line_itr_update
    if (state == ready_s)
        line_itr <= {# to_v(0) #};
    else if (state == setup_s)
        mp_accu_init <= mp_accu_part;
    else if (swap_ack)
    begin
        line_itr <= line_itr + {# to_v(1) #};
        mp_accu_init <= mp_accu_init - mp_accu_base;
    end
end

{% for i in [0, 1] %}
// swappable {#i#}
wire {# conf()['tShiftAccuBase'].verilog_decl() #} sw{#i#}_sh_accu_base;
wire {# conf()['tMapAccuInit'].verilog_decl() #} sw{#i#}_mp_accu_init;
wire {# conf()['tMapAccuBase'].verilog_decl() #} sw{#i#}_mp_accu_base;
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
