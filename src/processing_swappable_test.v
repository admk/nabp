{# include('templates/info.v') #}
// NABPProcessingSwappableTest
//     13 Feb 2012
// This test bench tests the functionality of NABPProcessingSwappable

module NABPProcessingSwappableTest();

{# include('templates/global_signal_generate.v') #}
{# include('templates/dump_wave.v') #}

// unit under test
NABPProcessingSwappable uut
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from swap control
    .sw_sh_accu_base(),
    .sw_mp_accu_init(),
    .sw_mp_accu_base(),
    .sw_swap_ack(),
    .sw_next_itr_ack(),
    // input from Filtered RAM
    .fr_val(),
    // outputs to swap control
    .sw_swap(),
    .sw_next_itr
    .sw_pe_en(),
    // output to RAM
    .fr_s_val(),
    // output to PEs
    .pe_taps()
);

endmodule
