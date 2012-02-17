{# include('templates/info.v') #}
// NABPProcessingDataPathVerify
//     16 Feb 2012
// This module verifies the data path for processing swappables by posing as
// a filtered RAM and each processing element

{#
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec, dec_repr

    no_pes = conf()['partition_scheme']['no_of_partitions']
    partition_size_len = bin_width_of_dec(partition_size)
    filtered_data_len = conf()['kFilteredDataLength']
    a_len = conf()['kAngleLength']
    s_val_len = bin_width_of_dec(conf()['projection_line_size'])
#}
`define kNoOfPartitions {# no_pes #}
`define kPartitionSizeLength {# partition_size_len #}
`define kAngleLength {# a_len #}
`define kSLength {# s_val_len #}
`define kFilteredDataLength {# filtered_data_len #}

module NABPProcessingDataPathVerify
(
    // global signals
    input wire clk,
    input wire reset_n,
    // host side
    input wire [`kAngleLength-1:0] tt_angle,
    input wire [`kPartitionSizeLength-1:0] tt_line_itr,
    // ram side
    input wire [`kSLength-1:0] pv_s_val,
    output reg [`kFilteredDataLength-1:0] pv_val,
    // pe side
    input wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps
);

// TODO implementation with PLI?

endmodule
