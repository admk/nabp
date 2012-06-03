{# include('templates/defines.v') #}
// NABPSinogramDataLUT
//     8 Mar 2012
// This module provides sinogram test data for testing purposes.

{#
    if not c['debug']:
        raise RuntimeError('Must be in debug mode to use this module.')
#}

module NABPSinogramDataLUT
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from nabp
    input wire [`kSinogramAddressLength-1:0] sg_addr,
    // outputs to nabp
    output reg [`kDataLength-1:0] sg_val
);

{# include('templates/python_path_update.v') #}

integer err;
initial
begin
    python_path_update();
    err = $pyeval(
        "from pynabp.conf.luts ",
        "import init_sinogram_defines, sinogram_lookup");
    err = $pyeval(
        "init_sinogram_defines(",
        {# c['projection_line_size'] #}, ",",
        {# c['angle_step_size'] #}, ",",
        {# c['kNoOfAngles'] #}, ",",
        {# c['kDataLength'] #}, ")");
end

integer sg_val_a;
always @(sg_addr)
    {% if 'processing_verify' in c['target'] %}
    sg_val_a = $pyeval("sinogram_lookup(", sg_addr, ", True)");
    {% else %}
    sg_val_a = $pyeval("sinogram_lookup(", sg_addr, ")");
    {% end %}
always @(posedge clk)
    sg_val <= sg_val_a;

endmodule
