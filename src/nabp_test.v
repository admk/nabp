{# include('templates/defines.v') #}
// NABPTest
//     7 Mar 2012
// This test bench tests the functionality of the top level NABP module

module NABPTest();

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

endmodule
