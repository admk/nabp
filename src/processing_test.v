{# include('templates/info.v') #}
// NABPProcessingSwappableTest
//     25 Feb 2012
// This test bench tests the functionality of NABPProcessingSwapControl

module NABPProcessingTest();

{# include('templates/global_signal_generate.v') #}
{# include('templates/dump_wave.v') #}

{# include('templates/data_test_vals.v') #}

// angles
wire hs_next_angle, hs_next_angle_ack, hs_has_next_angle;
wire [`kAngleLength-1:0] hs_angle;

// test values
{% for i in xrange(2) %}
reg [`kFilteredDataLength-1:0] fr{#i#}_val;
wire [`kSLength-1:0] fr{#i#}_s_val;
// data values
always @(posedge clk)
    fr{#i#}_val <= data_test_vals(fr{#i#}_s_val, hs_angle);
{% end %}

// unit under test
NABPProcessingSwapControl uut
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from filtered RAM swap control
    .fr_angle(hs_angle),
    .fr_next_angle_ack(hs_next_angle_ack),
    .fr0_val(fr0_val),
    .fr1_val(fr1_val),
    // output to processing elements
    .pe_reset(),
    .pe_kick(),
    .pe_en(),
    .pe_scan_mode(),
    .pe_scan_direction(),
    .pe_taps(),
    // output to RAM
    .fr_next_angle(hs_next_angle),
    .fr0_s_val(fr0_s_val),
    .fr1_s_val(fr1_s_val)
);

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

endmodule
