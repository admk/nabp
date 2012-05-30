{# include('templates/defines.v') #}
// NABP
//     6 Mar 2012
// The top level entity which encapsulates all components.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// S̲c̲h̲e̲m̲a̲t̲i̲c̲
//   __________________________
//  |       Sinogram RAM       | <- TODO caching
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅
//   _____________v̲____________
//  | ̲ ̲ ̲ ̲S̲i̲n̲o̲g̲r̲a̲m̲ ̲A̲d̲d̲r̲e̲s̲s̲e̲r̲ ̲ ̲ ̲ ̲| <- TODO rebinning
//  | ̲ ̲ ̲ ̲ ̲ ̲ ̲F̲I̲R̲ ̲F̲i̲l̲t̲e̲r̲i̲n̲g̲ ̲ ̲ ̲ ̲ ̲ ̲| <- TODO filtering
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
    input wire sg_kick,
    // inputs from sinogram
    input wire [`kDataLength-1:0] sg_val,
    // inputs from image RAM
    input wire ir_enable,
    // outputs to host
    output wire sg_done,
    // outputs to sinogram
    output wire [`kSinogramAddressLength-1:0] sg_addr,
    // outputs to image RAM
    output wire ir_kick,
    output wire ir_done,
    output wire [`kImageAddressLength-1:0] ir_addr,
    output wire [`kCacheDataLength-1:0] ir_val
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
    .hs_kick(sg_kick),
    // inputs from filtered RAM
    .fr_s_val(fr_sa_s_val),
    .fr_next_angle(fr_sa_next_angle),
    // outputs to host
    .hs_done(),
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
wire pr_prev_angle_release, pr_prev_angle_release_ack;
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
    .pr_prev_angle_release(pr_prev_angle_release),
    .pr_done(sg_done),
    // outputs to sinogram RAM
    .hs_s_val(fr_sa_s_val),
    // outputs to hs_angle_specification
    .hs_next_angle(fr_sa_next_angle),
    // outputs to processing swappables
    .pr_angle(pr_angle),
    .pr_has_next_angle(pr_has_next_angle),
    .pr_next_angle_ack(pr_next_angle_ack),
    .pr_prev_angle_release_ack(pr_prev_angle_release_ack),
    .pr0_val(pr0_val),
    .pr1_val(pr1_val)
);

wire pe_kick, pe_scan_mode, pe_scan_direction;
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
    .fr_prev_angle_release_ack(pr_prev_angle_release_ack),
    .fr_done(sg_done),
    .fr0_val(pr0_val),
    .fr1_val(pr1_val),
    // output to processing elements
    .pe_kick(pe_kick),
    .pe_scan_mode(pe_scan_mode),
    .pe_scan_direction(pe_scan_direction),
    .pe_taps(pe_taps),
    // output to RAM
    .fr_next_angle(pr_next_angle),
    .fr_prev_angle_release(pr_prev_angle_release),
    .fr0_s_val(pr0_s_val),
    .fr1_s_val(pr1_s_val)
);

wire [`kFilteredDataLength-1:0] pe_tap_val[`kNoOfPartitions-1:0];
wire pe_domino[`kNoOfPartitions:0];
wire [`kCacheDataLength-1:0] pe_domino_val[`kNoOfPartitions-1:0];

// domino connections
assign pe_domino[0] = sg_done;
assign ir_done = pe_domino[`kNoOfPartitions];
assign ir_val = pe_domino_val[`kNoOfPartitions-1];

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
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from swap control
    .sw_kick(pe_kick),
    .sw_scan_mode(pe_scan_mode),
    .sw_scan_direction(pe_scan_direction),
    // input from image RAM
    .ir_domino_enable(ir_enable),
    // input from line buffer
    .lb_val(pe_tap_val[{#i#}]),
    // inputs from the previous PE
    .pe_domino_kick(pe_domino[{#i#}]),
    .pe_in_val(
        {% if i == 0 %}
            0
        {% else %}
            pe_domino_val[{#i-1#}]
        {% end %}),
    // outputs to the next PE
    .pe_domino_done(pe_domino[{#i+1#}]),
    .pe_out_val(pe_domino_val[{#i#}])
);
{% end %}

NABPImageAddresser image_addresser
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from host
    .hs_kick(sg_done),
    // inputs from Image RAM
    .ir_enable(ir_enable),
    // outputs to image RAM
    .ir_kick(ir_kick),
    .ir_done(ir_done),
    .ir_addr(ir_addr)
);

endmodule
