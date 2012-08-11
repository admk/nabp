{# include('templates/defines.v') #}
// NABPProcessingSwapControl
//     24 Jan 2012
// Provides control for the swappables
// Handles swapping between the swappable instances
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
    input wire [`kAngleLength-1:0] fr0_angle,
    input wire [`kAngleLength-1:0] fr1_angle,
    input wire fr0_angle_valid,
    input wire fr1_angle_valid,
    input wire fr_next_angle_ack,
    input wire signed [`kFilteredDataLength-1:0] fr0_val,
    input wire signed [`kFilteredDataLength-1:0] fr1_val,
    // output to processing elements
    output wire pe_kick,
    output wire pe_scan_mode,
    output wire pe_scan_direction,
    output wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps,
    // output to RAM
    output wire fr_next_angle,
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

reg sel;
wire swap;

always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        state <= ready_s;
        sel <= 1'b0;
    end
    else
    begin
        state <= next_state;
        if (swap)
            sel <= !sel;
    end
end

// swappable wirings
{% for i in [0, 1] %}
wire sw{#i#}_fill_kick, sw{#i#}_fill_done;
wire sw{#i#}_shift_kick, sw{#i#}_shift_done;
{% end %}
// control signal multiplexers and demultiplexers
wire fill_done, fill_kick, shift_done, shift_kick;
always @(*)
begin:mux_and_demux
    if (sel)
    begin
        // to swappables
        sw0_fill_kick = `NO;
        sw1_fill_kick = fill_kick;
        sw0_shift_kick = shift_kick;
        sw1_shift_kick = `NO;
        // from swappables
        fill_done = sw0_fill_done;
        shift_done = sw1_shift_done;
    end
    else
    begin
        // to swappables
        sw0_fill_kick = fill_kick;
        sw1_fill_kick = `NO;
        sw0_shift_kick = `NO;
        sw1_shift_kick = shift_kick;
        // from swappables
        fill_done = sw1_fill_done;
        shift_done = sw0_shift_done;
    end
end

always @(*)
begin:mealy_output_update_internal
    swap <= `NO;
    case (state)
        fill_and_shift_setup_2_s:
            swap <= `YES;
    endcase
end

assign fr_done = // finished all angles, return to ready state
                 (next_state == ready_s);
always @(*)
begin:mealy_outputs_external
    fr_next_angle = `NO;
    case (state)
        fill_s:
            if (fill_done)
                fr_next_angle = `YES;
        fill_and_shift_s:
            if (fill_done && shift_done)
                fr_next_angle = `YES;
    endcase
end

always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case
        ready_s:
            if (fr_next_angle_ack)
                next_state <= setup_s;
        setup_1_s:
            next_state <= setup_2_s;
        setup_2_s:
            next_state <= fill_s;
        fill_s:
            if (fr_next_angle_ack)
                next_state <= fill_and_shift_setup_1_s;
        fill_and_shift_setup_1_s:
            next_state <= fill_and_shift_setup_2_s;
        fill_and_shift_setup_2_s:
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
    endcase
end

{% for i in [0, 1] %}
// swappable {#i#}
wire {# c['tShiftAccuBase'].verilog_decl() #} sw{#i#}_sh_accu_base;
wire {# c['tMapAccuInit'].verilog_decl() #} sw{#i#}_mp_accu_init;
wire {# c['tMapAccuBase'].verilog_decl() #} sw{#i#}_mp_accu_base;
wire [`kSLength-1:0] sw{#i#}_fr_s_val;
wire [`kFilteredDataLength-1:0] sw{#i#}_fr_val;
wire [`kFilteredDataLength*`kNoOfPartitions-1:0] sw{#i#}_pe_taps;
// wirings
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
