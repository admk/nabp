{# include('templates/defines.v') #}
// NABPTest
//     7 Mar 2012
// This test bench tests the functionality of the top level NABP module

module NABPTest();

{#
    include('templates/python_path_update.v')
    include('templates/global_signal_generate.v')
    include('templates/data_test_vals.v')
    include('templates/pe_dump.v')
    include('templates/dump_wave.v')

    if not c['debug']:
        raise RuntimeError('Must be in debug mode to perform this test.')
#}

initial
begin
    pe_dump_init();
end

reg kick;
wire sg_done;

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

always @(posedge clk)
begin:done_handler
    if (sg_done)
    begin
        pe_dump_finish();
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
    .reset_n(reset_n),
    // inputs from host
    .sg_kick(kick),
    // inputs from sinogram
    .sg_val(sg_val),
    // inputs from image RAM
    .ir_kick(0),
    .ir_enable(0),
    // outputs to host
    .sg_done(sg_done),
    // outputs to sinogram
    .sg_addr(sg_addr),
    // outputs to image RAM
    .ir_kick_ack(),
    .ir_done(),
    .ir_addr(),
    .ir_val()
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
