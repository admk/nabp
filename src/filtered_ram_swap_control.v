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
{#
    from pynabp.enums import filtered_ram_swap_control_states
#}

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
    output reg [`kSLength-1:0] hs_s_val,
    output reg hs_next_angle,
    // outputs to processing swappables
    output reg [`kAngleLength-1:0] pr0_angle,
    output reg [`kAngleLength-1:0] pr1_angle,
    output reg pr0_angle_valid,
    output reg pr1_angle_valid,
    output reg pr_next_angle_ack,
    output reg signed [`kFilteredDataLength-1:0] pr0_val,
    output reg signed [`kFilteredDataLength-1:0] pr1_val
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

reg rotate;
reg [`kRotateLength-1:0] rotate_sel;

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

// angle update
reg pr_angle_valid_d;
always @(posedge clk)
begin
    if (!reset_n)
    begin
        pr_angle_valid_d <= `NO;
        pr0_angle_valid <= `NO;
        pr1_angle_valid <= `NO;
    end
    else if (rotate)
    begin
        pr0_angle <= hs_angle;
        pr1_angle <= pr0_angle;
        pr_angle_valid_d <= hs_has_next_angle;
        pr0_angle_valid <= pr_angle_valid_d;
        pr1_angle_valid <= pr0_angle_valid;
    end
end

// Multiplexer and demultiplexer scheme
// ============ === === === ========================
//  rotate_sel   0   1   2   Description
// ------------ --- --- --- ------------------------
//  Order of     0   2   1   <- fill from host
//  buffers      1   0   2   -> fill to processing
//               2   1   0   -> shift to processing
// ============ === === === ========================
{% for i in range(rotate) %}
// signal wirings for swappable {#i#}
// inputs
reg sw{#i#}_fill_kick;
reg [`kSLength-1:0] sw{#i#}_pr0_s_val, sw{#i#}_pr1_s_val;
reg signed [`kFilteredDataLength-1:0] sw{#i#}_hs_val;
// outputs
wire sw{#i#}_fill_done;
wire [`kSLength-1:0] sw{#i#}_hs_s_val;
wire signed [`kFilteredDataLength-1:0] sw{#i#}_pr0_val, sw{#i#}_pr1_val;
{% end %}

reg fill_done, fill_kick;
always @(posedge clk)
begin:fill_kick_update
    fill_kick <= rotate;
end

{#
    rotates = []
    rotate_list = range(rotate)
    for _ in range(rotate):
        rotates.append(rotate_list)
        rotate_list = rotate_list[-1:] + rotate_list[:-1]
#}
always @(*)
begin:rotate_sel_mux
    // prevent latches
    hs_s_val <= 'bx;
    pr0_val <= 'bx;
    pr1_val <= 'bx;
    fill_done <= `NO;
    {% for i in range(rotate) %}
    sw{#i#}_pr0_s_val <= 'bx;
    sw{#i#}_pr1_s_val <= 'bx;
    sw{#i#}_fill_kick <= `NO;
    {% end %}
    // multiplexers and demultiplexers
    case (rotate_sel)
        {% for i, r in enumerate(rotates) %}
        {# to_r(i) #}:
        begin
            // outputs to host
            hs_s_val <= sw{#r[0]#}_hs_s_val;
            // inputs from processing swappables
            // processing filling, pr1 reserved
            sw{#r[1]#}_pr0_s_val <= pr0_s_val;
            // processing shifting, pr1 reserved
            sw{#r[2]#}_pr0_s_val <= pr1_s_val;
            // outputs to processing swappables
            pr0_val <= sw{#r[1]#}_pr0_val;
            pr1_val <= sw{#r[2]#}_pr0_val;
            // internal controls
            fill_done <= sw{#r[0]#}_fill_done && !fill_kick;
            sw{#r[0]#}_fill_kick <= fill_kick;
        end
        {% end %}
        default:
            if (reset_n)
                $display("<NABPFilteredRAMSwapControl>",
                    "Unrecognised rotate_sel: %d", rotate_sel);
    endcase
end

always @(*)
begin:rotate_update
    rotate <= `NO;
    hs_next_angle <= `NO;
    pr_next_angle_ack <= `NO;
    case (state)
        ready_s:
        begin
            hs_next_angle <= `YES;
            if (hs_next_angle_ack)
                rotate <= `YES;
        end
        fill_s:
            if (fill_done)
            begin
                hs_next_angle <= `YES;
                if (hs_next_angle_ack) 
                begin
                    rotate <= `YES;
                    pr_next_angle_ack <= `YES;
                end
            end
        fill_and_work_1_s, fill_and_work_2_s:
            if (fill_done && pr_next_angle)
            begin
                hs_next_angle <= hs_has_next_angle;
                if (~hs_has_next_angle || hs_next_angle_ack)
                begin
                    rotate <= `YES;
                    pr_next_angle_ack <= `YES;
                end
            end
        work_1_s:
            if (pr_next_angle)
            begin
                rotate <= `YES;
                pr_next_angle_ack <= `YES;
            end
        default:
        begin
            rotate <= `NO;
            hs_next_angle <= `NO;
            pr_next_angle_ack <= `NO;
        end
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
                next_state <= fill_and_work_1_s;
        fill_and_work_1_s:
            if (rotate)
                next_state <= fill_and_work_2_s;
        fill_and_work_2_s:
            if (rotate)
                if (hs_has_next_angle)
                    next_state <= fill_and_work_2_s;
                else
                    next_state <= work_1_s;
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
// swappable {#i#} instantiation
NABPFilteredRAMSwappable sw{#i#}
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from host
    .hs_fill_kick(sw{#i#}_fill_kick),
    .hs_val(hs_val),
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
