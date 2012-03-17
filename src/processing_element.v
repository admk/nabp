{# include('templates/defines.v') #}
// NABPProcessingElement
//     10 Jan 2012
// The processing element is a single unit with a cache to store value fed by
// the line buffer to the correct pixel location. Each processing element works
// with one tap of the line buffer.
//
// S̲c̲h̲e̲m̲a̲t̲i̲c̲
//  
//   ____________
//  |  Filtered  |
//  |  RAM Swap  |
//  |   Control  |
//    ̅ ̅ ̅ ̅ ̅|̅ ̅ ̅ ̅ ̅ ̅ ̅
//   _____v̲______
//  | Processing |
//  |    Swap  _ |    ____
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
    from pynabp.enums import scan_mode, scan_direction, \
            processing_element_states

    scan_mode_pixels = c['partition_scheme']['size'] * c['image_size']

    # two modes need an extra bit to address
    base_addr_len = bin_width(scan_mode_pixels - 1)
    addr_len = 1 + base_addr_len

    cache_size = 2 ** addr_len

    def to_base_addr(val):
        return dec_repr(val, base_addr_len)
#}
`define kAddressLength {# addr_len #}

module NABPProcessingElement
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from swap control
    input wire sw_kick,
    input wire sw_domino,
    input wire sw_scan_mode,
    input wire sw_scan_direction,
    // input from line buffer
    input wire signed [`kFilteredDataLength-1:0] lb_val
);

parameter integer pe_id = 'bz;
parameter [`kImageSizeLength-1:0] pe_tap_offset = 'bz;

{#
    include('templates/state_decl(states).v',
            states=processing_element_states())
#}

wire [`kAddressLength-1:0] addr;
reg [`kAddressLength-2:0] base_addr;
reg [`kImageSizeLength-1:0] scan_cnt;
assign addr = {sw_scan_mode, base_addr};

wire done, scan_done;
assign done = // PE must be working
              (state == work_s) &&
              // and base_addr reaches the end...
              ((sw_scan_direction == {# scan_direction.forward #}) ?
               // in the forward direction
               (base_addr == {# to_base_addr(scan_mode_pixels - 1) #}) :
               // or in the backward direction
               (base_addr == base_addr == {# to_base_addr(0) #}));
assign scan_done = // PE must be working
                  (state == work_s) &&
                  // counter has reached the end of a scan
                  (scan_cnt == {# to_i(c['image_size'] - 1) #});

always @(posedge clk)
begin:base_addr_counter
    if ((state == ready_s) && sw_kick)
    begin
        scan_cnt <= {# to_i(0) #};
        if (sw_scan_direction == {# scan_direction.forward #})
            base_addr <= {# to_base_addr(0) #};
        else if (sw_scan_direction == {# scan_direction.reverse #})
            base_addr <= {# to_base_addr(scan_mode_pixels - 1) #};
    end
    else if (state == work_s)
    begin
        scan_cnt <= scan_cnt + {# to_i(1) #};
        if (sw_scan_direction == {# scan_direction.forward #})
            base_addr <= base_addr + {# to_base_addr(1) #};
        else if (sw_scan_direction == {# scan_direction.reverse #})
            base_addr <= base_addr - {# to_base_addr(1) #};
    end
end

reg write_en;
reg [`kAddressLength-1:0] write_addr;
reg [`kCacheDataLength-1:0] write_val;
wire [`kCacheDataLength-1:0] read_val;

always @(posedge clk)
begin:write_back_sync
    write_en <= (state == work_s);
    write_addr <= addr;
    write_val <= read_val + lb_val;
end

always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

always @(*)
begin:mealy_next_state
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (sw_kick)
                next_state <= work_s;
            else if (sw_domino)
                next_state <= domino_s;
        work_s:
            if (done)
                next_state <= ready_s;
            else if (scan_done)
                next_state <= work_wait_s;
        work_wait_s:
            if (sw_kick)
                next_state <= work_s;
        domino_s:
            $display("Domino state: not implemented");
    endcase
end

NABPDualPortRAM
#(
    .pDataLength(`kCacheDataLength),
    .pRAMSize({# cache_size #}),
    .pAddrLength(`kAddressLength)
)
pe_cache
(
    .clk(clk),
    .clear(!reset_n), // TODO clear after domino complete
    // port 0 for writing
    .we_0(write_en),
    .addr_0(write_addr),
    .data_in_0(write_val),
    .data_out_0(),
    // port 1 for reading
    .we_1(0),
    .addr_1(addr),
    .data_in_1(0),
    .data_out_1(read_val)
);

{% if c['debug'] %}
integer err;
reg [`kImageSizeLength-1:0] im_x, im_y, scan_pos, line_pos;

always @(posedge clk)
    if (state == work_s)
    begin
        line_pos = base_addr / {# c['image_size'] #};
        scan_pos = base_addr - {# c['image_size'] #} * line_pos;
        line_pos = line_pos + pe_tap_offset;
        if (sw_scan_mode == {# scan_mode.x #})
        begin
            im_x = scan_pos;
            im_y = line_pos;
        end
        else
        begin
            im_x = line_pos;
            im_y = scan_pos;
        end
        err = $pyeval("test.update(", im_x, ",", im_y, ",", write_val, ")");
    end
{% end %}

endmodule
