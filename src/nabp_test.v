{# include('templates/defines.v') #}
// NABPTest
//     7 Mar 2012
// This test bench tests the functionality of the top level NABP module

module NABPTest();

{#
    include('templates/global_signal_generate.v')
    include('templates/dump_wave.v')
    include('templates/data_test_vals.v')

    if not c['debug']:
        raise RuntimeError('Must be in debug mode to perform this test.')
#}

reg kick;
wire done;

// control signals
always
begin:kick_done_handler
    kick = 0;
    @(posedge reset_n);
    @(posedge clk);
    kick = 1;
    @(posedge clk);
    kick = 0;
    @(posedge done);
end

// unit under test
NABP nabp_uut
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from host
    .kick(kick),
    // inputs from sinogram
    .sg_val(sg_val),
    // outputs to host
    .done(done),
    // outputs to sinogram
    .sg_addr(sg_addr)
);

// sinogram RAM
NABPSinogramDataLUT sinogram_lut
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from nabp
    .sg_addr(sg_addr),
    // outputs to nabp
    .sg_val(sg_val)
);

endmodule
