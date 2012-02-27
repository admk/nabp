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
    if (pr_next_angle_ack)
        pr_angle <= hs_angle;

// mealy outputs
assign swap_curr = hs_has_next_angle ?
                   hs_next_angle_ack : (fill_done && pr_next_angle);
assign hs_next_angle = reset_n &&
                       ((state == ready_s) ||
                       (hs_has_next_angle && fill_done && pr_next_angle));
assign fill_kick = swap && (next_state != work_s);
assign pr_next_angle_ack = (state != ready_s) && swap;

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
            if (swap)
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
