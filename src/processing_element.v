{# include('templates/info.v') #}
// NABPProcessingElement
//     10 Jan 2011
// Processing element
// ~~~~~~~~~~~~~~~~~~
//
// The processing element is operating in a mode that only the same number of
// caches are necessary.  The image is divided in 5x5 blocks. The access
// pattern (digits are caches and letters are PEs) for an image with
// 5 partitions is
//
//      E-> 5 1 2 3 4
//      D-> 4 5 1 2 3
//      C-> 3 4 5 1 2
//      B-> 2 3 4 5 1
//      A-> 1 2 3 4 5
//          ^ ^ ^ ^ ^
//          A B C D E
//
// In either scan mode (x or y), each PE accesses the caches in the same
// pattern at each iteration, and only one will be accessed by one PE at
// a time.
// The addresses for the caches are not packed (to avoid the use of
// multipliers). And they have the following scheme -
//
//      { cc_sel, y, x }
//
// The signal cc_sel is of length
//
//      ceil(log2(no_of_partitions))
//
// This is because a cache stores no_of_partitions blocks of the image. (For
// example cache no. 5 stores the diagonal blocks of the image.)

{#
    from pynabp.conf import conf
    from pynabp.enums import scan_mode
    from pynabp.utils import bin_width_of_dec, dec_repr

    data_len = conf()['kFilteredDataLength']
    partition_size = conf()['partition_scheme']['size']
    partition_size_len = bin_width_of_dec(partition_size)
    no_partitions = conf()['partition_scheme']['no_of_partitions']
    no_partitions_len = bin_width_of_dec(no_partitions)
    image_size = conf()['image_size']
    addr_len = partition_size_len * 2 + no_partitions_len
#}

`define kNoPartitions {# no_partitions #}
`define kNoPartitonsLength {# no_partitions_len #}
`define kFilteredDataLength {# data_len #}
`define kPartitionSizeLength {# partition_size_len #}
`define kAddressLength {# addr_len #}

module NABPProcessingElement
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from swap control
    input wire sw_kick,
    input wire sw_en,
    input wire sw_scan_mode,
    // input from line buffer
    input wire signed [`kFilteredDataLength-1:0] lb_val,
    // inputs from cache control
    input wire signed [`kFilteredDataLength-1:0] cc_read_val,
    // outputs to cache control
    output unsigned [`kNoPartitonsLength-1:0] cc_sel,
    output wire [`kAddressLength-1:0] cc_read_addr,
    output reg cc_write_en,
    output reg [`kAddressLength-1:0] cc_write_addr,
    output reg signed [`kFilteredDataLength-1:0] cc_write_val
);

parameter [`kNoPartitonsLength-1:0] id = {# dec_repr(0, no_partitions_len) #};

reg unsigned [`kPartitionSizeLength-1:0] line_itr;
reg unsigned [`kPartitionSizeLength-1:0] scan_itr;
reg unsigned [`kNoPartitonsLength:0] scan_sec;
wire [`kNoPartitonsLength-1:0] cc_sec_sel;
{# cc_sel_max = dec_repr(no_partitions, no_partitions_len + 1) #}
assign cc_sel = (scan_sec < {# cc_sel_max #}) ?  scan_sec :
                (scan_sec - {# cc_sel_max #});
assign cc_sec_sel = (sw_scan_mode == {# scan_mode.y #}) ? id : scan_sec;
assign cc_read_addr = (sw_scan_mode == {# scan_mode.x #} ? 
                      {cc_sec_sel, line_itr, scan_itr} :
                      {cc_sec_sel, scan_itr, line_itr};

{#
    def to_v(val):
        return dec_repr(val, partition_size_len)
#}
always @(posedge clk)
begin:counter
    if (!reset_n)
    begin
        line_itr <= {# to_v(0) #};
        scan_itr <= {# to_v(0) #};
        scan_sec <= {0, id};
    end else
    begin
        if (sw_kick)
        begin
            line_itr <= line_itr + {# to_v(1) #};
            scan_itr <= {# to_v(0) #};
            scan_sec <= {0, id};
        end
        else if (sw_en)
        begin
            line_itr <= line_itr;
            if (scan_itr == {# to_v(partition_size) #})
            begin
                scan_itr <= {# to_v(0) #};
                scan_sec <= scan_sec +
                        {# dec_repr(0, no_partitions_len + 1) #};
            end
            else
                scan_itr <= scan_itr + {# to_v(1) #};
                scan_sec <= scan_sec;
            end
        end
    end
end

always @(posedge clk)
begin:cc_write
    cc_write_en <= sw_en;
    cc_write_addr <= cc_read_addr;
    cc_write_val <= cc_read_val + lb_val;
end

endmodule
