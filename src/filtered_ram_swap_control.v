{# include('templates/defines.v') #}
// NABPFilteredRAMSwapControl
//     5 Feb 2012
// Controls the swapping between filtered RAM swappables
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Filtering is done as illustrated below
//   _____                                           ______________
//  |     |<___a̲d̲d̲r̲e̲s̲s̲______________________________|              |
//  | RAM |____d̲a̲t̲a̲_     _____     _f̲i̲l̲t̲e̲r̲e̲d̲ ̲d̲a̲t̲a̲__>| Filtered RAM |
//  |_____|         |   |     |   |                 | Swap Control |
//                  |__>| FIR |___|                 |______________|
//                      |_____|
// The delay between the correspondence between address and data is handled by
// NABPFilteredRAMSwappable.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//               <<has>>                     <<has>>
// Dual Port RAM ------> FilteredRAMSwappable -----> FilteredRAMSwapControl
// FIR is not in NABPFilteredRAMSwapControl to make early testing easier.
// Possible TODO: refactor FIR to be a part of NABPFilteredRAMSwapControl.

module NABPFilteredRAMSwapControl
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from host
    input wire [`kAngleLength-1:0] hs_angle,
    input wire hs_has_next_angle,
    input wire hs_next_angle_ack,
    // input from filter
    input wire [`kFilteredDataLength-1:0] hs_val,
    // inputs from processing swappables
    input wire [`kSLength-1:0] pr0_s_val,
    input wire [`kSLength-1:0] pr1_s_val,
    input wire pr_next_angle,
    input wire pr_done,
    // outputs to host RAM
    output wire [`kSLength-1:0] hs_s_val,
    output wire hs_next_angle,
    // outputs to processing swappables
    output reg [`kAngleLength-1:0] pr_angle,
    output wire pr_next_angle_ack,
    output wire signed [`kFilteredDataLength-1:0] pr0_val,
    output wire signed [`kFilteredDataLength-1:0] pr1_val
);

{#
    # TODO update states
    include('templates/state_decl(states).v',
            states=filtered_ram_swap_control_states())

    rotate = 3

    def to_r(val):
        return dec_repr(val, bin_width(rotate))
#}

`define kRotate {# rotate #}
`define kRotateLength {# bin_width(rotate) #}

wire rotate;
reg [`kRotateLength-1:0] rotate_sel;

{% for i in swap_list %}
// signal wirings for swappable {#i#}
// inputs
wire sw{#i#}_fill_kick;
wire [`kSLength-1:0] sw{#i#}_pr0_s_val, sw{#i#}_pr1_s_val;
wire signed [`kFilteredDataLength-1:0] sw{#i#}_hs_val;
// outputs
wire sw{#i#}_fill_done;
wire [`kSLength-1:0] sw{#i#}_hs_s_val;
wire signed [`kFilteredDataLength-1:0] sw{#i#}_pr0_val, sw{#i#}_pr1_val;
{% end %}

// mealy state transition
always @(posedge clk)
begin:transition
    if (!reset_n)
    begin
        state <= ready_s;
        rotate_sel <= {# to_r(0) #};
    end
    else
    begin
        state <= next_state;
        if (rotate)
            if (rotate_sel == {# to_r(rotate - 1) #})
                rotate_sel <= {# to_r(0) #};
            else
                rotate_sel <= rotate_sel + {# to_r(1) #};
    end
end

wire fill_done, fill_kick;

always @(*)
begin:rotate_sel_mux
    // default outputs
    sw0_fill_kick = 1'b0;
    sw1_fill_kick = 1'b0;
    sw2_fill_kick = 1'b0;
    // multiplexers and demultiplexers
    case (rotate_sel)
        2'd0:
        begin
            fill_done = sw1_fill_done;
            sw2_fill_kick = 1'b1;
        end
        2'd1:
        begin
            fill_done = sw2_fill_done;
            sw0_fill_kick = 1'b1;
        end
        2'd2:
        begin
            fill_done = sw0_fill_done;
            sw1_fill_kick = 1'b1;
        end
        default:
            if (reset_n)
                $display("<NABPFilteredRAMSwapControl>"
                    "Unrecognised rotate_sel: %d", rotate_sel);
    endcase
end

always @(*)
begin:rotate_update
    rotate = 1'b0;
    case (state)
        ready_s:
            if (hs_next_angle_ack)
                rotate = 1'b1;
        fill_s:
            if (fill_done)
                rotate = 1'b1;
        fill_and_work_s, fill_and_work_repeat_s:
            if (fill_done && pr_next_angle)
                rotate = 1'b1;
        work_1_s:
            if (pr_next_angle)
                rotate = 1'b1;
    endcase
end

// mealy next state
always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case
        ready_s:
            if (rotate)
                next_state <= fill_s;
        fill_s:
            if (rotate)
                next_state <= fill_and_work_s;
        fill_and_work_s:
            if (rotate)
                next_state <= fill_and_work_repeat_s;
        fill_and_work_repeat_s:
            if (rotate)
                if (hs_has_next_angle)
                    next_state <= work_1_s;
                else
                    next_state <= fill_and_work_repeat_s;
        work_1_s:
            if (rotate)
                next_state <= work_2_s;
        work_2_s:
            if (pr_done)
                next_state <= ready_s;
        default:
            if (reset_n)
                $display("<NABPFilteredRAMSwapControl> Invalid state: %d",
                    state);
    endcase
end

{% for i in range(rotate) %}
// signal wirings for swappable {#i#}
assign sw{#i#}_pr0_s_val = pr0_s_val;
assign sw{#i#}_pr1_s_val = pr1_s_val;
assign sw{#i#}_hs_val = hs_val;

// swappable {#i#} instantiation
NABPFilteredRAMSwappable sw{#i#}
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from host
    .hs_fill_kick(sw{#i#}_fill_kick),
    .hs_val(sw{#i#}_hs_val),
    // inputs from processing swappables
    .pr0_s_val(sw{#i#}_pr0_s_val),
    .pr1_s_val(sw{#i#}_pr1_s_val),
    // outputs to host
    .hs_fill_done(sw{#i#}_fill_done),
    .hs_s_val(sw{#i#}_hs_s_val),
    // outputs to processing swappables
    .pr0_val(sw{#i#}_pr0_val),
    .pr1_val(sw{#i#}_pr1_val)
);
{% end %}

endmodule
