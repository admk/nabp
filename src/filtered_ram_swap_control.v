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
    swap_list = range(2)
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
    input wire pr_prev_angle_release,
    // outputs to host RAM
    output wire [`kSLength-1:0] hs_s_val,
    output wire hs_next_angle,
    // outputs to processing swappables
    output reg [`kAngleLength-1:0] pr_angle,
    output reg pr_has_next_angle,
    output wire pr_next_angle_ack,
    output wire pr_prev_angle_release_ack,
    output wire signed [`kFilteredDataLength-1:0] pr0_val,
    output wire signed [`kFilteredDataLength-1:0] pr1_val
);

{#
    include('templates/state_decl(states).v',
            states=filtered_ram_swap_control_states())
#}

// swappable mux & demux select signal
//       S̲e̲l̲e̲c̲t̲ ̲T̲a̲b̲l̲e̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲ ̲
//      | ̲s̲w̲_̲s̲e̲l̲ ̲|̲ ̲s̲w̲0̲ ̲ ̲ ̲ ̲ ̲|̲ ̲s̲w̲1̲ ̲ ̲ ̲ ̲ ̲|
//      | 0      | working | filling |
//      | ̲1̲ ̲ ̲ ̲ ̲ ̲ ̲|̲ ̲f̲i̲l̲l̲i̲n̲g̲ ̲|̲ ̲w̲o̲r̲k̲i̲n̲g̲ ̲|
reg sw_sel;

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

wire fill_done, fill_kick;
assign fill_done = sw_sel ? sw0_fill_done : sw1_fill_done;
assign sw0_fill_kick = sw_sel ? 0 : fill_kick;
assign sw1_fill_kick = sw_sel ? fill_kick : 0;
assign hs_s_val = sw_sel ? sw0_hs_s_val : sw1_hs_s_val;

reg swap_prev;
wire swap, swap_curr;
assign swap = (!swap_prev && swap_curr);
always @(posedge clk)
begin:swap_pulse
    if (!reset_n)
        swap_prev <= 0;
    else
        swap_prev <= swap_curr;
end
// angle update
always @(posedge clk)
    if (!reset_n)
    begin
        // must have some angle for processing
        pr_has_next_angle <= 1;
    end
    else if (pr_next_angle_ack || pr_prev_angle_release_ack)
    begin
        pr_angle <= hs_angle;
        pr_has_next_angle <= hs_has_next_angle;
    end

// F̲i̲l̲t̲e̲r̲e̲d̲ ̲R̲A̲M̲ ̲S̲w̲a̲p̲p̲a̲b̲l̲e̲ ̲-̲>̲ ̲P̲r̲o̲c̲e̲s̲s̲i̲n̲g̲ ̲S̲w̲a̲p̲p̲a̲b̲l̲e̲ ̲D̲a̲t̲a̲ ̲P̲a̲t̲h̲ ̲R̲o̲u̲t̲i̲n̲g̲ ̲S̲c̲h̲e̲m̲e̲
// Diverging allows two processing swappables to work on two different angles
// simultaneously. It happens after pr_next_angle_ack response, and then
// allowed to continue after pr_prev_angle_release_ack.  The routing is
// handled by processing swappable, filtered RAM swappable only cares about
// how buffer swapping should be handled.
//
//    [A] ̶* ̶>[0]   / [A] ̶*  [0]
//        |       /      |
//    [B] ̶*  [1] /   [B] ̶* ̶>[1]
//     (sw_sel)       (!sw_sel)
//       {fill_and_work_s}
//
// after pr_next_angle_ack -
//
//    [A] ̶ ̶ ̶>[0]   / [A] ̶x ̶>[0]
//                /      |      (swapped)
//    [B] ̶ ̶ ̶>[1] /   [B] ̶x ̶>[1]
//
//        {diverged_work_s}
//
// after pr_prev_angle_release_ack -
//
//    [A] ̶*  [0]   / [A] ̶* ̶>[0]
//        |       /      |
//    [B] ̶* ̶>[1] /   [B] ̶*  [1]
//     (!sw_sel)      (sw_sel)
//        {fill_and_work_s}
//
//    [A/B]: Filtered swappables
//    [0/1]: Processing swappables

// mealy outputs
// to processing
wire prev_angle_release;
assign prev_angle_release = // release oldest angle if want next angle and
                            pr_prev_angle_release &&
                            // fill done
                            fill_done &&
                            // only when advancing, not diverging
                            (// if filling then discard dirty working buffer
                             // to fill immediately after fill done
                             (state == fill_s) ||
                             // if diverging done then we need the next buffer
                             // to become the current main buffer, and fill the
                             // old buffer
                             (state == diverged_work_s));
assign pr_prev_angle_release_ack = (state != ready_s) &&
                                   // acknowledgement happens when needed and
                                   pr_prev_angle_release &&
                                   // swap happens because prev_angle_release
                                   swap;
assign pr_next_angle_ack = (state != ready_s) &&
                           (// acknowledgement happens when either swapped
                            (// or ready to get into diverge state when needed
                             // because the next buffer is done filling
                             pr_next_angle && fill_done &&
                             // and the only state when diverging is possible
                             (state == fill_and_work_s)));
// to host
assign hs_next_angle = // request for the next angle when ready or
                       (reset_n && state == ready_s) ||
                       // requested by release signal
                       prev_angle_release;
// internal
assign fill_kick = // kicks when wanted to swap and
                   swap &&
                   // has next angle to start with
                   hs_has_next_angle;
assign swap_curr = hs_has_next_angle ?
                   // swap when host responds for next angle request
                   hs_next_angle_ack :
                   // or no new angle available, simply wait for release
                   prev_angle_release;

// mealy state transition
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
        if (swap)
            sw_sel <= !sw_sel;
    end
end

// mealy next state
always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (hs_next_angle_ack)
                next_state <= fill_s;
        fill_s:
            if (swap)
                if (hs_has_next_angle)
                    next_state <= fill_and_work_s;
                else
                    next_state <= work_s;
        fill_and_work_s:
            if (pr_next_angle_ack)
                next_state <= diverged_work_s;
        diverged_work_s:
            if (pr_prev_angle_release_ack)
                if (hs_has_next_angle)
                    next_state <= fill_and_work_s;
                else
                    next_state <= work_s;
        work_s:
            if (fill_done)
                next_state <= ready_s;
    endcase
end

{% for i in swap_list %}
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

assign pr0_val = sw_sel ? sw1_pr0_val : sw0_pr0_val;
assign pr1_val = sw_sel ? sw1_pr1_val : sw0_pr1_val;

endmodule
