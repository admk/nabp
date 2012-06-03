{# include('templates/defines.v') #}
// NABPTest
//     7 Mar 2012
// This test bench tests the functionality of the top level NABP module

module NABPTest();

{#
    include('templates/python_path_update.v')
    include('templates/global_signal_generate.v')
    include('templates/data_test_vals.v')
    include('templates/dump_wave.v')

    if not c['debug']:
        raise RuntimeError('Must be in debug mode to perform this test.')
#}

reg sg_kick;
wire sg_done, ir_kick, ir_done, ir_enable;

{% if 'reconstruction_test' in c['target'] %}
{# include('templates/image_dump(image_name).v', image_name='pe_dump') #}
initial
    image_dump_init();
always @(posedge clk)
    if (sg_done)
        image_dump_finish();
{% end %}

// control signals
initial
begin:kick_handler
    @(posedge reset_n);
    sg_kick = 0;
    @(posedge clk);
    sg_kick = 1;
    @(posedge clk);
    sg_kick = 0;
end

always @(posedge clk)
begin:done_handler
    if (ir_done)
    begin
        @(posedge clk);
        @(posedge clk);
        $finish;
    end
end

wire [`kDataLength-1:0] sg_val;
wire [`kSinogramAddressLength-1:0] sg_addr;
wire ir_addr_valid;
wire [`kImageAddressLength-1:0] ir_addr;
wire [`kCacheDataLength-1:0] ir_val;

// unit under test
NABP nabp_uut
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from host
    .sg_kick(sg_kick),
    // inputs from sinogram
    .sg_val(sg_val),
    // inputs from image RAM
    .ir_enable(ir_enable),
    // outputs to host
    .sg_done(sg_done),
    // outputs to sinogram
    .sg_addr(sg_addr),
    // outputs to image RAM
    .ir_kick(ir_kick),
    .ir_done(ir_done),
    .ir_addr_valid(ir_addr_valid),
    .ir_addr(ir_addr),
    .ir_val(ir_val)
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

// image RAM
NABPImageRAM image_ram
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from image addresser
    .ir_kick(ir_kick),
    .ir_done(ir_done),
    .ir_addr_valid(ir_addr_valid),
    .ir_addr(ir_addr),
    .ir_val(ir_val),
    // output to image addresser & processing elements
    .ir_enable(ir_enable)
);

endmodule
