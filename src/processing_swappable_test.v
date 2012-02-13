{# include('templates/info.v') #}
// NABPProcessingSwappableTest
//     13 Feb 2012
// This test bench tests the functionality of NABPProcessingSwappable

{#
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec, dec_repr
    filtered_data_len = conf()['kFilteredDataLength']
    a_len = conf()['kAngleLength']
    s_val_len = bin_width_of_dec(conf()['projection_line_size'])
#}
`define kAngleLength {# a_len #}
`define kSLength {# s_val_len #}
`define kFilteredDataLength {# filtered_data_len #}

module NABPProcessingSwappableTest();

{# include('templates/global_signal_generate.v') #}
{# include('templates/dump_wave.v') #}

reg [`kAngleLength-1:0] hs_angle;
wire {# conf()['tShiftAccuBase'].verilog_decl() #} sw_sh_accu_base;
wire {# conf()['tMapAccuInit'].verilog_decl() #} sw_mp_accu_init;
wire {# conf()['tMapAccuBase'].verilog_decl() #} sw_mp_accu_base;
wire [`kSLength-1:0] fr_s_val;
reg [`kFilteredDataLength-1:0] fr_val;

// a simple preliminary test for 45 degrees
// currently only tests controls
initial
begin:hs_angle_update
    hs_angle = {# dec_repr(45, a_len) #};
end

always @(posedge clk)
    // a simple preliminary test with values exactly equals to the s_val
    fr_val <= fr_s_val;

// controls
reg sw_swap_ack, sw_next_itr_ack;
wire sw_swap, sw_next_itr, sw_pe_en;
wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps;

always @(posedge clk)
begin:control_test_signals
    // always send acks to requests with 1 cycle delay
    sw_swap_ack <= sw_swap;
    sw_next_itr_ack <= sw_next_itr;
end

// unit under test
NABPProcessingSwappable uut
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from swap control
    .sw_sh_accu_base(sw_sh_accu_base),
    .sw_mp_accu_init(sw_mp_accu_init),
    .sw_mp_accu_base(sw_mp_accu_base),
    .sw_swap_ack(sw_swap_ack),
    .sw_next_itr_ack(sw_next_itr_ack),
    // input from Filtered RAM
    .fr_val(fr_val),
    // outputs to swap control
    .sw_swap(sw_swap),
    .sw_next_itr(sw_next_itr),
    .sw_pe_en(sw_pe_en),
    // output to RAM
    .fr_s_val(fr_s_val),
    // output to PEs
    .pe_taps(pe_taps)
);

// look-up tables
wire {# conf()['tMapAccuPart'].verilog_decl() #} sw_mp_accu_part;
assign sw_mp_accu_init = sw_mp_accu_part; // implicit sign extension
NABPMapperLUT mapper_lut
(
    .clk(clk),
    .mp_angle(hs_angle),
    .mp_accu_part(sw_mp_accu_part), // iteration 0
    .mp_accu_base(sw_mp_accu_base)
);
NABPShifterLUT shifter_lut
(
    // inputs
    .clk(clk),
    .sh_angle(hs_angle),
    // output
    .sh_accu_base(sw_sh_accu_base)
);

endmodule
