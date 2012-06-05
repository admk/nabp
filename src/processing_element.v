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
// D̲̲o̲̲m̲̲i̲̲n̲̲o̲̲ ̲̲S̲i̲̲g̲̲n̲̲a̲̲l̲̲ ̲̲A̲s̲̲s̲̲i̲̲g̲̲n̲̲m̲̲e̲̲n̲̲t̲̲ ̲a̲c̲r̲o̲s̲s̲ ̲P̲r̲o̲c̲e̲s̲s̲i̲n̲g̲ ̲E̲l̲e̲m̲e̲n̲t̲s̲
//
// ir_kick
//     |
//    _v̲_
//   | 0 | ̶/̶ ̶ ̶ ̶*  domino val out
//     ̅|̅ ̅      |
//    _v̲_      |
//   | 1 | ̶/̶ ̶* |
//     ̅|̅|̅    | |
//     |* ̶ ̶>\M̲̅U̲̅X̲̅/ select signal: domino or ready states
//     |       |
//     |       |
//    _v̲_      |
//   | 2 | ̶/̶ ̶* |
//     ̅|̅|̅    | |
//     |* ̶ ̶>\M̲̅U̲̅X̲̅/
//     |       |
//
//        ⋮
//     |       |
//    _v̲_      |
//   |N-1| ̶/̶ ̶* |
//     ̅ ̅|̅    | |
//      * ̶ ̶>\M̲̅U̲̅X̲̅/
//            |
//            * ̶ ̶> ir_val
//
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
    input wire sw_scan_mode,
    input wire sw_scan_direction,
    // input from image RAM
    input wire ir_domino_enable,
    // input from line buffer
    input wire signed [`kFilteredDataLength-1:0] lb_val,
    // inputs from the previous PE
    input wire pe_domino_kick,
    input wire signed [`kCacheDataLength-1:0] pe_in_val,
    // outputs to the next PE
    output wire pe_domino_done,
    output wire signed [`kCacheDataLength-1:0] pe_out_val
    {% if c['debug'] %},
    input wire [`kAngleLength-1:0] pe_angle
    {% end %}
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
wire done, scan_done, scan_domino_done, scan_domino_mode;

assign scan_domino_mode = (state == domino_start_s || state == domino_0_s) ?
                          0 : 1;
assign addr = {(state == work_s) ? sw_scan_mode : scan_domino_mode, base_addr};

assign done = // PE must be working
              (state == work_s) &&
              // and base_addr reaches the end...
              ((sw_scan_direction == {# scan_direction.forward #}) ?
               // in the forward direction
               (base_addr == {# to_base_addr(scan_mode_pixels - 1) #}) :
               // or in the reverse direction
               (base_addr == {# to_base_addr(0) #}));
assign scan_done = // PE must be working
                   (state == work_s) &&
                   // counter has reached the end of a scan
                   (scan_cnt == {# to_i(0) #});
assign scan_domino_done = // PE must be in one of the domino modes
                          (state == domino_0_s || state == domino_1_s) &&
                          // counter has reached the end of a scan for all
                          // pixels
                          (base_addr ==
                           {# to_base_addr(scan_mode_pixels - 1) #});

assign pe_domino_done = // all domino operations are complete
                        (state == domino_finish_s);

assign pe_out_val = (state == domino_0_s ||
                     state == domino_1_s ||
                     state == domino_finish_s) ? read_val : pe_in_val_d;
reg [`kCacheDataLength-1:0] pe_in_val_d;
always @(posedge clk)
    if (ir_domino_enable)
        pe_in_val_d <= pe_in_val;

// T̲i̲m̲i̲n̲g̲ ̲D̲i̲a̲g̲r̲a̲m̲ ̲f̲o̲r̲ ̲P̲r̲o̲c̲e̲s̲s̲i̲n̲g̲ ̲E̲l̲e̲m̲e̲n̲t̲ ̲D̲o̲m̲i̲n̲o̲ ̲C̲h̲a̲i̲n̲
// [ext]
//
//          clk _| ̅ ̅ ̅|___| ̅ ̅ ̅|___| ̅ ̅ ̅|_       ___| ̅ ̅ ̅|___| ̅ ̅ ̅|___| ̅ ̅ ̅|___| ̅ ̅ ̅|
//
//     ir_do_en _/ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅        ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅ ̅
//
// [pe0]
//  pe0_do_kick _/ ̅ ̅ ̅ ̅ ̅ ̅ ̅\_____________       ________________________________
//
//    pe0_state _̅_̅r̲̅e̲̅a̲̅d̲̅y̲̅_̅_̅X_̅d̲̅o̲̅m̲̅_̲̅s̲̅_̅X_̅d̲̅o̲̅m̲̅_̅       _̅_̅d̲̅o̲̅m̲̅_̅_̅_̅_̅_̅_̅X_̅d̲̅o̲̅m̲̅_̲̅f̲̅_̅X_̅r̲̅e̲̅a̲̅d̲̅y̲̅_̅_̅_̅_̅_̅_̅
//
//     pe0_addr X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X_̅_̅_̅N̲̅_̅_̅_̅X_̅N̲̅-̲̅1̲̅_̅       _̅1̲̅_̅X_̅_̅_̅0̲̅_̅_̅_̅XX̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅
//                                       ...
//  pe0_out_val X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X_̅[̲̅N̲̅]̲̅_̅       [̲̅2̲̅]̲̅X_̅_̅[̲̅1̲̅]̲̅_̅_̅X_̅_̅[̲̅0̲̅]̲̅_̅_̅XX̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅
//
//  pe0_do_done _______________________       ___________/ ̅ ̅ ̅ ̅ ̅ ̅ ̅\____________
//
// [pe1]
//  pe1_do_kick _______________________       ___________/ ̅ ̅ ̅ ̅ ̅ ̅ ̅\____________
//
//    pe1_state _̅_̅r̲̅e̲̅a̲̅d̲̅y̲̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅       _̅_̅r̲̅e̲̅a̲̅d̲̅y̲̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅_̅X_̅d̲̅o̲̅m̲̅_̲̅s̲̅_̅X_̅d̲̅o̲̅m̲̅
//
//     pe1_addr X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅       X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X_̅_̅_̅N̲̅_̅_̅_̅X_̅_̅_̅_̅
//
//  pe1_out_val X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X̲̅X_̅_̅_̅_̅_̅       _̅_̅_̅X_̅_̅[̲̅2̲̅]̲̅_̅_̅X_̅_̅[̲̅1̲̅]̲̅_̅_̅X_̅_̅[̲̅0̲̅]̲̅_̅_̅X_̅[̲̅N̲̅]̲̅
//
// [comments]
//           pe0 value generate  |-----       -------------------|
//               pe1 value feed out from pe0  ---------------------------|
//                                                   pe1 value generate  |----
always @(posedge clk)
begin:base_addr_counter
    case (state)
        ready_s:
            if (sw_kick)
            begin
                scan_cnt <= {# to_i(c['image_size'] - 1) #};
                if (sw_scan_direction == {# scan_direction.forward #})
                    base_addr <= {# to_base_addr(0) #};
                else if (sw_scan_direction == {# scan_direction.reverse #})
                    base_addr <= {# to_base_addr(scan_mode_pixels - 1) #};
            end
            else if (pe_domino_kick)
                base_addr <= {# to_base_addr(0) #};
        work_wait_s:
            scan_cnt <= {# to_i(c['image_size'] - 1) #};
        work_s:
        begin
            scan_cnt <= scan_cnt - {# to_i(1) #};
            if (sw_scan_direction == {# scan_direction.forward #})
                base_addr <= base_addr + {# to_base_addr(1) #};
            else if (sw_scan_direction == {# scan_direction.reverse #})
                base_addr <= base_addr - {# to_base_addr(1) #};
        end
        domino_start_s, domino_0_s, domino_1_s:
            if (ir_domino_enable)
            begin
                if (scan_domino_done)
                    base_addr <= {# to_base_addr(0) #};
                else
                    base_addr <= base_addr + {# to_base_addr(1) #};
            end
    endcase
end

reg write_en;
reg [`kAddressLength-1:0] write_addr;
wire [`kCacheDataLength-1:0] write_val;
wire [`kCacheDataLength-1:0] read_val;

assign write_val = read_val + lb_val;
always @(posedge clk)
begin:write_back_sync
    write_en <= (state == work_s);
    write_addr <= addr;
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
            else if (pe_domino_kick)
                next_state <= domino_start_s;
        work_s:
            if (done)
                next_state <= ready_s;
            else if (scan_done)
                next_state <= work_wait_s;
        work_wait_s:
            if (sw_kick)
                next_state <= work_s;
        domino_start_s:
            next_state <= domino_0_s;
        domino_0_s:
            if (ir_domino_enable && scan_domino_done)
                next_state <= domino_1_s;
        domino_1_s:
            if (ir_domino_enable && scan_domino_done)
                next_state <= domino_finish_s;
        domino_finish_s:
            if (ir_domino_enable)
                next_state <= ready_s;
        default:
            if (reset_n)
                $display("<NABPProcessingElement> Invalid state: %d", state);
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

{#
    pe_verify = False

    if 'processing_verify' in c['target']:
        pe_verify = True
        include('templates/processing_verify.v')

    if 'reconstruction_test' in c['target']:
        pe_verify = True
        include('templates/image_dump(image_name).v', image_name='pe_dump')
#}
{% if pe_verify %}
integer err, im_x, im_y, scan_pos, line_pos, expected_lb_val;
reg [`kAddressLength-2:0] base_addr_d;

always @(posedge clk)
    base_addr_d <= base_addr;

integer dump_val;
always @(posedge clk)
    if (write_en)
    begin
        line_pos = base_addr_d / {# c['image_size'] #};
        scan_pos = base_addr_d - {# c['image_size'] #} * line_pos;
        line_pos = line_pos + pe_tap_offset;
        im_x = (sw_scan_mode == {# scan_mode.x #}) ? scan_pos : line_pos;
        im_y = (sw_scan_mode == {# scan_mode.x #}) ? line_pos : scan_pos;
        dump_val = lb_val;

        {% if 'processing_verify' in c['target'] %}
            expected_lb_val = expected_s_val(pe_angle, im_x, im_y);
            {% if 'processing_addressing_verify' in c['target'] %}
                dump_val = $pyeval("sinogram_lookup(",
                    pe_angle / {# c['angle_step_size'] #} *
                    `kProjectionLineSize + expected_lb_val, ")");
            {% end %}
        {% end %}
        {% if 'reconstruction_test' in c['target'] %}
            image_dump_pixel(im_x, im_y, dump_val);
        {% end %}
    end
{% end %}

{% if 'domino_test' in c['target'] %}
always @(state)
    if (state == domino_start_s)
        $display("domino: %d", pe_id);
{% end %}

endmodule
