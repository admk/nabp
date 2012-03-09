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
//  | ̲ ̲ ̲ ̲S̲i̲n̲o̲g̲r̲a̲m̲ ̲A̲d̲d̲r̲e̲s̲s̲e̲r̲ ̲ ̲ ̲ ̲| <- TODO rebinning
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
// S̲i̲n̲o̲g̲r̲a̲m̲ ̲R̲A̲M̲ ̲f̲o̲r̲m̲a̲t̲
// TODO write proper description

module NABP
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from host
    input wire kick,
    // inputs from sinogram
    input wire [`kDataLength-1:0] sg_val,
    // TODO inputs from image RAM
    // outputs to host
    output wire done,
    // outputs to sinogram
    output wire [`kSinogramAddressLength-1:0] sg_addr
    // TODO outputs to image RAM
);

wire [`kAngleLength-1:0] sa_fr_angle;
wire sa_fr_has_next_angle, sa_fr_next_angle_ack, fr_sa_next_angle;
wire [`kSLength-1:0] fr_sa_s_val;
NABPSinogramAddresser sinogram_addresser
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from host
    .hs_kick(kick),
    // inputs from filtered RAM
    .fr_s_val(fr_sa_s_val),
    .fr_next_angle(fr_sa_next_angle),
    // outputs to host
    .hs_done(done),
    // outputs to filtered RAM
    .fr_angle(sa_fr_angle),
    .fr_has_next_angle(sa_fr_has_next_angle),
    .fr_next_angle_ack(sa_fr_next_angle_ack),
    // outputs to sinogram RAM
    .sg_addr(sg_addr)
);

wire [`kFilteredDataLength-1:0] fl_fr_val;
NABPFilter filter
(
    .clk(clk),
    .enable(1'd1),
    .clear(fr_sa_next_angle),
    .val_in(sg_val),
    .val_out(fl_fr_val)
);

wire [`kAngleLength-1:0] pr_angle;
wire pr_next_angle, pr_next_angle_ack, pr_has_next_angle;
wire [`kSLength-1:0] pr0_s_val, pr1_s_val;
wire [`kFilteredDataLength-1:0] pr0_val, pr1_val;
NABPFilteredRAMSwapControl filtered_ram_swap_control
(
    .clk(clk),
    .reset_n(reset_n),
    // inputs from addresser
    .hs_angle(sa_fr_angle),
    .hs_has_next_angle(sa_fr_has_next_angle),
    .hs_next_angle_ack(sa_fr_next_angle_ack),
    // input from filter
    .hs_val(fl_fr_val),
    // inputs from processing swappables
    .pr0_s_val(pr0_s_val),
    .pr1_s_val(pr1_s_val),
    .pr_next_angle(pr_next_angle),
    // outputs to sinogram RAM
    .hs_s_val(fr_sa_s_val),
    // outputs to hs_angle_specification
    .hs_next_angle(fr_sa_next_angle),
    // outputs to processing swappables
    .pr_angle(pr_angle),
    .pr_has_next_angle(pr_has_next_angle),
    .pr_next_angle_ack(pr_next_angle_ack),
    .pr0_val(pr0_val),
    .pr1_val(pr1_val)
);

wire pe_reset, pe_en, pe_scan_mode, pe_scan_direction;
wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps;
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
    .pe_en(pe_en),
    .pe_scan_mode(pe_scan_mode),
    .pe_scan_direction(pe_scan_direction),
    .pe_taps(pe_taps),
    // output to RAM
    .fr_next_angle(pr_next_angle),
    .fr0_s_val(pr0_s_val),
    .fr1_s_val(pr1_s_val)
);

wire [`kFilteredDataLength-1:0] pe_tap_val[`kNoOfPartitions-1:0];
{% for i in xrange(c['partition_scheme']['no_of_partitions']) %}
assign pe_tap_val[{#i#}] = pe_taps[
        `kFilteredDataLength*{#i+1#}-1:`kFilteredDataLength*{#i#}];
NABPProcessingElement 
#(
    .pe_id({#i#}),
    .pe_tap_offset({# c['partition_scheme']['partitions'][i] #})
)
processing_element_{#i#}
(
    .clk(clk),
    .sw_reset(pe_reset),
    .sw_en(pe_en),
    .sw_scan_mode(pe_scan_mode),
    .sw_scan_direction(pe_scan_direction),
    .lb_val(pe_tap_val[{#i#}])
);
{% end %}

endmodule