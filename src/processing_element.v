{# include('templates/defines.v') #}
// NABPProcessingElement
//     10 Jan 2011
// The processing element is a single unit with a cache to store value fed by
// the line buffer to the correct pixel location. Each processing element works
// with one tap of the line buffer.
//
// S̲c̲h̲e̲m̲a̲t̲i̲c̲
//   ____________
//  | Processing |
//  | Swap     _ |    ____
//  | Control | ||̶ ̶ ̶>| PE |--*
//  |         |L||    _̅_̅_̅_̅   |
//  |         |i||̶ ̶ ̶>| PE |--*
//  |         |n||    _̅_̅_̅_̅   |
//  |         |e||̶ ̶ ̶>| PE |--*
//  |         | ||    _̅_̅_̅_̅   |
//  |         |B||̶ ̶ ̶>| PE |--*
//  |         |u||    _̅_̅_̅_̅   |
//  |         |f||̶ ̶ ̶>| PE |--*
//  |         |f||    _̅_̅_̅_̅   |
//  |         |e||̶ ̶ ̶>| PE |--*    ___________
//  |         |r||    _̅_̅_̅_̅   |   |           |
//  |         | ||̶ ̶ ̶>| PE |--*-->| Image RAM |
//  |           ̅ |     ̅ ̅ ̅ ̅       |           |
//    ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅                  ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅
// C̲o̲m̲m̲e̲n̲t̲s̲ ̲o̲n̲ ̲a̲d̲d̲r̲e̲s̲s̲ ̲p̲a̲c̲k̲i̲n̲g̲
// Address packing for the two scan modes won't have any effect, since -
//     $\log_2{2il}=\log_2{il}+1$,
// where $i$ is the image size, and $l$ is the line iteration
{#
    from pynabp.enums import scan_mode, scan_direction

    scan_mode_pixels = c['partition_scheme']['size'] * c['image_size']

    # two modes need an extra bit to address
    base_addr_len = bin_width(scan_mode_pixels - 1)
    addr_len = 1 + base_addr_len

    def to_base_addr(val):
        return dec_repr(val, base_addr_len)
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

wire [`kAddressLength-1:0] addr;
reg [`kAddressLength-2:0] base_addr;
assign addr = {scan_mode, base_addr};

always @(posedge clk)
begin:base_addr_counter
    if (sw_reset)
    begin
        if (sw_scan_direction == {# scan_direction.forward #})
            base_addr <= {# to_base_addr(0) #};
        else if (sw_scan_direction == {# scan_direction.reverse #})
            base_addr <= {# to_base_addr(scan_mode_pixels - 1) #};
    end
    else if (sw_en)
    begin
        if (sw_scan_direction == {# scan_direction.forward #})
            if (base_addr == {# to_base_addr(scan_mode_pixels - 1) #})
                base_addr <= {# to_base_addr(0) #};
            else
                base_addr <= base_addr + {# to_base_addr(1) #};
        else if (sw_scan_direction == {# scan_direction.reverse #})
            if (base_addr == {# to_base_addr(0) #})
                base_addr <= {# to_base_addr(scan_mode_pixels - 1) #};
            else
                base_addr <= base_addr - {# to_base_addr(1) #};
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
