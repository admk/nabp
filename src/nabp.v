{# include('templates/defines.v') #}
// NABP
//     6 Mar 2012
// The top level entity which encapsulates all components.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// S̲c̲h̲e̲m̲a̲t̲i̲c̲
//   __________________________
//  |       Sinogram RAM       |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅
//   _____________v̲____________
//  | ̲ ̲ ̲ ̲ ̲ ̲TODO ̲R̲e̲b̲i̲n̲n̲i̲n̲g̲ ̲ ̲ ̲ ̲ ̲ ̲|
//  | Filtered RAM Swap Control|
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅
//   _____________v̲____________
//  | Processing Swap Control  |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅
//   _____________v̲____________
//  |   Processing Elements    |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅  <- TODO implement processing element data out.
//   _____________v̲____________
//  |         Image RAM        |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅

module NABP
(
    // global signals
    input wire clk,
    input wire reset_n,
    // TODO inputs from Sinogram RAM
    // TODO inputs from Image RAM
    // TODO outputs to Sinogram RAM
    // TODO outputs to Image RAM
);

wire [`kAngleLength-1:0] hs_angle;
wire hs_has_next_angle, hs_next_angle_ack, hs_next_angle;
wire [`kSLength-1:0] hs_s_val;
wire [`kDataLength-1:0] hs_unfiltered_val;
// TODO NABPSinogramAddresser

wire [`kFilteredDataLength-1:0] hs_val;
// TODO filtering
NABPFilterSkeleton filter
(
    .clk(clk),
    .enable(1'd1),
    .clear(hs_next_angle),
    .val_in(hs_unfiltered_val),
    .val_out(hs_val)
);

wire [`kAngleLength-1:0] pr_angle;
wire pr_next_angle, pr_next_angle_ack;
wire [`kSLength-1:0] pr0_s_val, pr1_s_val;
wire [`kFilteredDataLength-1:0] pr0_val, pr1_val;
NABPFilteredRAMSwapControl filtered_ram_swap_control
(
    .clk(clk),
    .reset_n(reset_n),
    // inputs from addresser
    .hs_angle(hs_angle),
    .hs_has_next_angle(hs_has_next_angle),
    .hs_next_angle_ack(hs_next_angle_ack),
    // input from filter
    .hs_val(hs_val),
    // inputs from processing swappables
    .pr0_s_val(pr0_s_val),
    .pr1_s_val(pr1_s_val),
    .pr_next_angle(pr_next_angle),
    // outputs to sinogram RAM
    .hs_s_val(hs_s_val),
    // outputs to hs_angle_specification
    .hs_next_angle(hs_next_angle),
    // outputs to processing swappables
    .pr_angle(pr_angle),
    .pr_next_angle_ack(pr_next_angle_ack),
    .pr0_val(pr0_val),
    .pr1_val(pr1_val)
);

wire pe_reset, pe_en, pe_scan_mode, pe_scan_direction;
// TODO pe_taps unpacking
NABPProcessingSwapControl processing_swap_control
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from filtered RAM swap control
    .fr_angle(pr_angle),
    .fr_has_next_angle(pr_has_next_angle),
    .fr_next_angle_ack(pr_next_angle_ack),
    .fr0_val(pr0_val),
    .fr1_val(pr1_val),
    // output to processing elements
    .pe_reset(pe_reset),
    .pe_kick(),
    .pe_en(pe_en),
    .pe_scan_mode(pe_scan_mode),
    .pe_scan_direction(pe_scan_direction),
    .pe_taps(pe_taps),
    // output to RAM
    .fr_next_angle(pr_next_angle),
    .fr0_s_val(pr0_s_val),
    .fr1_s_val(pr1_s_val)
);

{% for i in xrange(c['no_of_processing_elements']) %}
NABPProcessingElement 
#(
    .pe_id({#i#}),
    .pe_tap_offset({# c['partition_scheme']['partitions'][i] #})
)
processing_element
(
    .clk(clk),
    .sw_reset(pe_reset),
    .sw_en(pe_en),
    .sw_scan_mode(pe_scan_mode),
    .sw_scan_direction(pe_scan_direction),
    .lb_val()
);
{% end %}

endmodule
