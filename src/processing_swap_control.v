{# include('templates/defines.v') #}
// NABPProcessingSwapControl
//     24 Jan 2012
// Provides control for the swappables
// Handles swapping between the swappable instances
{#
    from pynabp.enums import \
            processing_swap_control_states, scan_mode, scan_direction

    swap = 2
#}

module NABPProcessingSwapControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from filtered RAM swap control
    input wire [`kAngleLength-1:0] fr0_angle,
    input wire [`kAngleLength-1:0] fr1_angle,
    input wire fr0_angle_valid,
    input wire fr1_angle_valid,
    input wire fr_next_angle_ack,
    input wire signed [`kFilteredDataLength-1:0] fr0_val,
    input wire signed [`kFilteredDataLength-1:0] fr1_val,
    // output to processing elements
    output reg pe_kick,
    output reg pe_scan_mode,
    output reg pe_scan_direction,
    output reg [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps,
    // output to RAM
    output reg fr_next_angle,
    output wire fr_done,
    output wire signed [`kSLength-1:0] fr0_s_val,
    output wire signed [`kSLength-1:0] fr1_s_val
    {% if c['debug'] %},
    // debug signals
    output wire [`kAngleLength-1:0] db_angle
    {% end %}
);

{#
    include('templates/state_decl(states).v',
            states=processing_swap_control_states())
#}

reg sel, swap;

always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        state <= ready_s;
        sel <= `NO;
    end
    else
    begin
        state <= next_state;
        if (swap)
            sel <= !sel;
    end
end

// swappable wirings
{% for i in range(swap) %}
reg sw{#i#}_fill_kick, sw{#i#}_shift_kick;
wire sw{#i#}_pe_kick;
wire sw{#i#}_shift_done, sw{#i#}_fill_done;
wire [`kSLength-1:0] sw{#i#}_fr_s_val;
wire [`kFilteredDataLength-1:0] sw{#i#}_fr_val;
wire [`kFilteredDataLength*`kNoOfPartitions-1:0] sw{#i#}_pe_taps;
{% end %}

reg fill_done, fill_kick, shift_done, shift_kick;
// control signal multiplexers and demultiplexers
{#
    swaps = []
    swap_list = range(swap)
    for _ in range(swap):
        swaps.append(swap_list)
        swap_list = swap_list[-1:] + swap_list[:-1]
#}
always @(*)
begin:mux_and_demux
    // initialisations
    {% for i in range(swap) %}
    sw{#i#}_fill_kick <= `NO;
    sw{#i#}_shift_kick <= `NO;
    {% end %}
    pe_taps <= 'bx;
    pe_kick <= `NO;
    fill_done <= `NO;
    shift_done <= `NO;
    case (sel)
        {% for i, r in enumerate(swaps) %}
        {# to_b(i) #}:
        begin
            // to swappables
            sw{#r[1]#}_fill_kick <= fill_kick;
            sw{#r[0]#}_shift_kick <= shift_kick;
            // to PEs
            pe_taps <= sw{#r[1]#}_pe_taps;
            pe_kick <= sw{#r[1]#}_pe_kick;
            // from swappables
            fill_done <= sw{#r[0]#}_fill_done;
            shift_done <= sw{#r[1]#}_shift_done;
        end
        {% end %}
        default:
            if (reset_n)
                $display("<NABPProcessingSwapControl>",
                    "Unrecognised sel: %d", sel);
    endcase
end

// datapath muxing & demuxing
assign fr0_s_val = (sel == {# to_b(0) #}) ? sw0_fr_s_val : sw1_fr_s_val;
assign fr1_s_val = (sel == {# to_b(0) #}) ? sw1_fr_s_val : sw0_fr_s_val;
assign sw0_fr_val = (sel == {# to_b(0) #}) ? fr0_val : fr1_val;
assign sw1_fr_val = (sel == {# to_b(0) #}) ? fr1_val : fr0_val;

always @(fr1_angle)
begin:scan_modes_update
    // initialisation
    pe_scan_mode <= 'bx;
    pe_scan_direction <= 'bx;
    // assignments
    if (fr1_angle < `kAngle45 || fr1_angle >= `kAngle135)
        pe_scan_mode <= {# scan_mode.x #};
    else
        pe_scan_mode <= {# scan_mode.y #};
    if (fr1_angle < `kAngle90)
        pe_scan_direction <= {# scan_direction.forward #};
    else
        pe_scan_direction <= {# scan_direction.reverse #};
end

always @(state)
begin:mealy_output_update_internal
    swap <= `NO;
    case (state)
        setup_3_s, fill_and_shift_setup_3_s:
            swap <= `YES;
    endcase
end

assign fr_done = // finished all angles, return to ready state
                 (state != ready_s && next_state == ready_s);
always @(*)
begin:mealy_outputs_external
    fr_next_angle <= `NO;
    case (state)
        ready_s:
            fr_next_angle <= `YES;
        fill_s:
            if (fill_done)
                fr_next_angle <= `YES;
        fill_and_shift_s:
            if (fill_done && shift_done)
                fr_next_angle <= `YES;
    endcase
end

always @(*)
begin:mealy_outputs_internal
    fill_kick <= `NO;
    shift_kick <= `NO;
    if (state == setup_3_s || state == fill_and_shift_setup_3_s)
    begin
        fill_kick <= fr0_angle_valid;
        shift_kick <= fr1_angle_valid;
    end
end

always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case
        ready_s:
            if (fr_next_angle_ack)
                next_state <= setup_1_s;
        setup_1_s:
            next_state <= setup_2_s;
        setup_2_s:
            next_state <= setup_3_s;
        setup_3_s:
            next_state <= fill_s;
        fill_s:
            if (fr_next_angle_ack)
                next_state <= fill_and_shift_setup_1_s;
        fill_and_shift_setup_1_s:
            next_state <= fill_and_shift_setup_2_s;
        fill_and_shift_setup_2_s:
            next_state <= fill_and_shift_setup_3_s;
        fill_and_shift_setup_3_s:
            if (fr0_angle_valid)
                next_state <= fill_and_shift_s;
            else
                next_state <= shift_s;
        fill_and_shift_s:
            if (fr_next_angle_ack)
                next_state <= fill_and_shift_setup_1_s;
        shift_s:
            if (shift_done)
                next_state <= ready_s;
        default:
            if (reset_n)
                $display("<NABPProcessingSwapControl>",
                    "Unrecognised state: %d", state);
    endcase
end

wire {# c['tShiftAccuBase'].verilog_decl() #} sh_accu_base;
wire {# c['tMapAccuPart'].verilog_decl() #} mp_accu_part;
wire {# c['tMapAccuBase'].verilog_decl() #} mp_accu_base;

{% for i in range(swap) %}
// swappable {#i#}
wire {# c['tShiftAccuBase'].verilog_decl() #} sw{#i#}_sh_accu_base;
wire {# c['tMapAccuInit'].verilog_decl() #} sw{#i#}_mp_accu_init;
wire {# c['tMapAccuBase'].verilog_decl() #} sw{#i#}_mp_accu_base;
// wirings
assign sw{#i#}_sh_accu_base = sh_accu_base;
assign sw{#i#}_mp_accu_init = mp_accu_part;
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
    .sw_swap_ack(sw{#i#}_shift_kick),
    .sw_next_itr_ack(sw{#i#}_fill_kick),
    // inputs from Filtered RAM
    .fr_val(sw{#i#}_fr_val),
    // outputs to swap control
    .sw_swap(sw{#i#}_fill_done),
    .sw_next_itr(sw{#i#}_shift_done),
    .sw_pe_kick(sw{#i#}_pe_kick),
    // outputs to Filtered RAM
    .fr_s_val(sw{#i#}_fr_s_val),
    // outputs to PEs
    .pe_taps(sw{#i#}_pe_taps)
);
{% end %}

// look-up tables
NABPMapperLUT mapper_lut
(
    // inputs
    .clk(clk),
    .mp_angle(fr0_angle),
    // outputs
    .mp_accu_part(mp_accu_part),
    .mp_accu_base(mp_accu_base)
);
NABPShifterLUT shifter_lut
(
    // inputs
    .clk(clk),
    .sh_angle(fr0_angle),
    // output
    .sh_accu_base(sh_accu_base)
);

{% if c['debug'] %}
assign db_angle = fr1_angle;
{% end %}

endmodule
