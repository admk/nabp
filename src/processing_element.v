{# include('templates/defines.v') #}
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
    from pynabp.enums import scan_mode

    partition_size = c['partition_scheme']['size']
    partition_size_len = bin_width(partition_size)
    no_partitions = c['partition_scheme']['no_of_partitions']
    no_partitions_len = bin_width(c['partition_scheme']['no_of_partitions'])
    addr_len = partition_size_len * 2 + no_partitions_len

    def to_l(val):
        return dec_repr(val, partition_size_len)
    def to_sel(val):
        return dec_repr(val, no_partitions_len)
#}
`define kAddressLength {# addr_len #}

module NABPProcessingElement
(
    // global signals
    input wire clk,
    // inputs from swap control
    input wire sw_reset,
    input wire sw_kick,
    input wire sw_en,
    input wire sw_scan_mode,
    input wire sw_scan_direction,
    // input from line buffer
    input wire signed [`kFilteredDataLength-1:0] lb_val,
    // inputs from cache control
    input wire signed [`kFilteredDataLength-1:0] cc_read_val,
    // outputs to cache control
    output reg unsigned [`kNoOfPartitonsLength-1:0] cc_sel,
    output wire [`kAddressLength-1:0] cc_read_addr,
    output reg cc_write_en,
    output reg [`kAddressLength-1:0] cc_write_addr,
    output reg signed [`kFilteredDataLength-1:0] cc_write_val
);

parameter [`kNoOfPartitonsLength-1:0] pe_id = 'bz;
parameter [`kImageSizeLength-1:0] pe_tap = 'bz;

reg unsigned [`kPartitionSizeLength-1:0] line_itr;
reg unsigned [`kPartitionSizeLength-1:0] scan_itr;
reg unsigned [`kNoOfPartitonsLength-1:0] scan_sec;
wire [`kNoOfPartitonsLength-1:0] cc_sec_sel;
assign cc_sec_sel = (sw_scan_mode == {# scan_mode.y #}) ? pe_id : scan_sec;
assign cc_read_addr = (sw_scan_mode == {# scan_mode.x #} ? 
                      {cc_sec_sel, line_itr, scan_itr} :
                      {cc_sec_sel, scan_itr, line_itr};

always @(posedge clk)
begin:counter
    if (sw_reset)
    begin
        line_itr <= {# to_l(0) #};
        scan_itr <= {# to_l(0) #};
        scan_sec <= {# to_sel(0) #};
        cc_sel <= pe_id;
    end
    else if (sw_kick)
    begin
        line_itr <= line_itr + {# to_l(1) #};
        scan_itr <= {# to_l(0) #};
        scan_sec <= {# to_sel(0) #};
        cc_sel <= pe_id;
    end
    else if (sw_en)
    begin
        if (scan_itr == {# to_l(partition_size - 1) #})
        begin
            scan_itr <= {# to_l(0) #};
            scan_sec <= scan_sec + {# to_sel(1) #};
            if (cc_sel == {# to_sel(no_partitions - 1) #})
                cc_sel <= {# to_sel(0) #};
            else
                cc_sel <= cc_sel + {# to_sel(1) #};
        end
    end
end

always @(posedge clk)
begin:cc_write
    cc_write_en <= sw_en;
    cc_write_addr <= cc_read_addr;
    cc_write_val <= cc_read_val + lb_val;
end

{% if c['debug'] %}
integer file, err;
reg [20*8:1] file_name;
reg unsigned [`kImageSizeLength-1:0] im_x, im_y, scan_pos, line_pos;
initial
begin
    $sprintf(file_name, "pe_update_%d.csv", pe_id);
    file = $fopen(file_name, "w");
    $fwrite(file, "Time, X, Y, Value");
    always @(posedge clk)
        if (cc_write_en)
        begin
            scan_pos = {#
                    dec_repr(partition_size, bin_width(c['image_size']))
                #} * scan_sec + scan_itr;
            line_pos = pe_tap + line_itr;
            if (sw_scan_mode == {# scan_mode.x #})
            begin
                im_x = scan_pos;
                im_y = line_pos;
            end else
            begin
                im_x = line_pos;
                im_y = scan_pos;
            end
            $fwrite(file, "%g, %d, %d, %d\n", $time, im_x, im_y, cc_write_val);
            err = $fflush(file);
        end
end
{% end %}

endmodule
