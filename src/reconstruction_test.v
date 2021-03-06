{# include('templates/defines.v') #}
// NABPReconstructionTest
//     7 Mar 2012
// This test bench tests the reconstructed image output of the processing
// elements with processing swap control providing values.

module NABPReconstructionTest();

{#
    include('templates/python_path_update.v')
    include('templates/global_signal_generate.v')
    include('templates/data_test_vals.v')
    include('templates/dump_wave.v')

    if not c['debug']:
        raise RuntimeError('Must be in debug mode to perform this test.')
#}

reg kick;
wire done;

// control signals
initial
begin:kick_handler
    @(posedge reset_n);
    kick = 0;
    @(posedge clk);
    kick = 1;
    @(posedge clk);
    kick = 0;
end

{% if 'reconstruction_test' in c['target'] %}
{# include('templates/image_dump(image_name).v', image_name='pe_dump') #}
initial
    image_dump_init();
always @(posedge clk)
    if (done)
        image_dump_finish();
{% end %}

always @(posedge clk)
begin:done_handler
    if (done)
    begin
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
end

wire [`kDataLength-1:0] sg_val;
wire [`kSinogramAddressLength-1:0] sg_addr;

// unit under test
NABP nabp_uut
(
    // global signals
    .clk(clk),
    .clk_fast(clk_fast),
    .reset_n(reset_n),
    // inputs from host
    .sg_kick(kick),
    // inputs from sinogram
    .sg_val(sg_val),
    // inputs from image RAM
    .ir_enable(0),
    // outputs to host
    .sg_done(done),
    // outputs to sinogram
    .sg_addr(sg_addr),
    // outputs to image RAM
    .ir_kick(),
    .ir_done(),
    .ir_addr_valid(),
    .ir_addr(),
    .ir_val()
);

// sinogram RAM
NABPSinogramDataLUT sinogram_lut
(
    // global signals
    .clk(clk_fast),
    .reset_n(reset_n),
    // inputs from nabp
    .sg_addr(sg_addr),
    // outputs to nabp
    .sg_val(sg_val)
);

endmodule
