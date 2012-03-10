{# include('templates/defines.v') #}
// NABPProcessingSwappableTest
//     25 Feb 2012
// This test bench tests the functionality of NABPProcessingSwapControl

module NABPProcessingTest();

{#
    include('templates/global_signal_generate.v')
    include('templates/dump_wave.v')
    include('templates/data_test_vals.v')

    if not c['debug']:
        raise RuntimeError('Must be in debug mode to perform this test.')
#}

// angles
wire hs_next_angle, hs_next_angle_ack, hs_has_next_angle;
wire [`kAngleLength-1:0] hs_angle;

// angle value generator
hs_angles angles_generate
(
    .clk(clk),
    .reset_n(reset_n),
    .hs_next_angle(hs_next_angle),
    .hs_next_angle_ack(hs_next_angle_ack),
    .hs_angle(hs_angle),
    .hs_has_next_angle(hs_has_next_angle)
);

wire pe_en;
wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps;
wire [`kAngleLength-1:0] pe_angle;
wire [`kPartitionSizeLength-1:0] pe_line_itr;
wire [`kFilteredDataLength-1:0] fr0_val, fr1_val;
wire [`kSLength-1:0] fr0_s_val, fr1_s_val;

// unit under test
NABPProcessingSwapControl uut
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from filtered RAM swap control
    .fr_angle(hs_angle),
    .fr_has_next_angle(hs_has_next_angle),
    .fr_next_angle_ack(hs_next_angle_ack),
    .fr0_val(fr0_val),
    .fr1_val(fr1_val),
    // output to processing elements
    .pe_reset(),
    .pe_en(pe_en),
    .pe_scan_mode(),
    .pe_scan_direction(),
    .pe_taps(pe_taps),
    // output to RAM
    .fr_next_angle(hs_next_angle),
    .fr0_s_val(fr0_s_val),
    .fr1_s_val(fr1_s_val),
    // debug signals
    .db_angle(pe_angle),
    .db_line_itr(pe_line_itr)
);

// data path verifier
NABPProcessingDataPathVerify
#(
    .pVerbose(0)
)
data_path_verify
(
    // globals
    .clk(clk),
    .reset_n(reset_n),
    // host side
    .tt_angle(pe_angle),
    .tt_line_itr(pe_line_itr),
    // ram side
    .pv0_s_val(fr0_s_val),
    .pv1_s_val(fr1_s_val),
    .pv0_val(fr0_val),
    .pv1_val(fr1_val),
    // pe side
    .pe_en(pe_en),
    .pe_taps(pe_taps)
);

endmodule
