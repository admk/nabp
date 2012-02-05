{# include('templates/info.v') #}
// NABPSwapControl
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
// | sw_sel  | 0    | 1    |
// |_________|______|______|
// | inputs  | 0->a | 0->b |
// |         | 1->b | 1->a |
// |_________|______|______|
// | outputs | a->0 | a->1 |
// |         | b->1 | b->0 |
// |_________|______|______|
{#
    from pynabp.conf import conf
    from pynabp.enums import swap_control_states, scan_mode
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

module NABPSwapControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from host
    input wire unsigned [`kAngleLength-1:0] hs_angle,
    input wire hs_next_angle_ack,
    // input from Filtered RAM
    input wire signed [`kFilteredDataLength-1:0] fr0_val,
    input wire signed [`kFilteredDataLength-1:0] fr1_val,
    // outputs to host
    output wire hs_next_angle,
    // output to processing elements
    output wire pe_reset,
    output wire pe_kick,
    output wire pe_en,
    output wire pe_scan_mode,
    output wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps,
    // output to RAM
    output wire signed [`kSLength-1:0] fr0_s_val,
    output wire signed [`kSLength-1:0] fr1_s_val
);

{# include('templates/state_decl(states).v', states=swap_control_states()) #}

// line iteration
reg unsigned [`kPartitionSizeLength-1:0] line_itr;

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
wire swb_next_itr;
wire swa_next_itr_ack, swb_next_itr_ack;
wire swap_ack;
wire has_next_itr;
assign swa_swap = sw_sel ? sw1_swap : sw0_swap;
assign swb_next_itr = sw_sel ? sw0_next_itr : sw1_next_itr;
assign swap_ack = (state == fill_s or state == fill_and_shift_s) and
                  (swa_swap and swb_next_itr);
assign swa_next_itr_ack = (state == setup_s and hs_next_angle_ack);
assign swb_next_itr_ack = (has_next_itr and swap_ack);
assign sw0_next_itr_ack = sw_sel ? swb_next_itr_ack : swa_next_itr_ack;
assign sw1_next_itr_ack = sw_sel ? swa_next_itr_ack : swb_next_itr_ack;
assign sw0_swap_ack = sw_sel ? 0 : swap_ack;
assign sw1_swap_ack = sw_sel ? swap_ack : 0;
assign hs_next_angle = (next_state == ready_s);
assign has_next_itr = (line_itr != {# to_v(partition_size_len - 1) #});

always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        state <= setup_s;
        sw_sel <= 0;
    end
    else
    begin
        state <= next_state;
        if (swap_ack)
            sw_sel <= !sw_sel;
    end
end

always @(state)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (hs_next_angle_ack)
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
            if (swap_ack and !has_next_itr)
                next_state <= shift_s;
        shift_s:
            if (swb_next_itr)
                next_state <= ready_s;
        default:
            $display(
                "<NABPSwapControl> Invalid state encountered: %d", state);
    endcase
end

// pe control outputs
reg scan_mode;
assign pe_en = sw_sel ? sw1_pe_en : sw0_pe_en;
assign pe_reset = swa_next_itr_ack;
assign pe_kick = swap_ack;
assign pe_scan_mode = scan_mode;
always @(posedge clk)
begin:pe_setup
    if (state == setup_s)
        if (hs_angle < `kAngle45 or hs_angle >= `kAngle135)
            scan_mode <= {# scan_mode.x #};
        else
            scan_mode <= {# scan_mode.y #};
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
NABPSwappable sw{#i#}
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
    .mp_angle(hs_angle),
    // outputs
    .mp_accu_part(mp_accu_part),
    .mp_accu_base(mp_accu_base)
);
NABPShifterLUT shifter_lut
(
    // inputs
    .clk(clk),
    .sh_angle(hs_angle),
    // output
    .sh_accu_base(sh_accu_base)
);

// PE taps values
assign pe_taps = sw_sel ? sw0_pe_taps : sw1_pe_taps;

endmodule
