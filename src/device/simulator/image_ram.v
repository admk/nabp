{# include('templates/defines.v') #}
// NABPImageRAM
//     30 May 2012
{#
    from pynabp.enums import image_ram_states
#}

module NABPImageRAM
(
    // global signals
    input wire clk,
    input wire reset_n,
    // inputs from image addresser
    input wire ir_kick,
    input wire ir_done,
    input wire [`kImageAddressLength-1:0] ir_addr,
    input wire [`kCacheDataLength-1:0] ir_val,
    // output to image addresser & processing elements
    output wire ir_enable
);

{#
    include('templates/image_dump(image_name).v', image_name='image_ram')
    include('templates/state_decl(states).v', states=image_ram_states())
#}

// always high for ir_enable
assign ir_enable = 1;

// mealy outputs
wire working;
assign working = (state == work_s);

// mealy next state
always @(*)
begin:next_state_update
    next_state <= state;
    case (state) // synopsys parallel_case full_case
        ready_s:
            if (ir_kick)
                next_state <= work_s;
        work_s:
            if (ir_done)
                next_state <= ready_s;
    endcase
end

// mealy state transition
always @(posedge clk)
begin:transition
    if (!reset_n)
        state <= ready_s;
    else
        state <= next_state;
end

reg [`kImageSizeLength-1:0] im_x, im_y;

always @(posedge clk)
begin:image_ram_update
    if (working && ir_addr < `kImageNoOfPixels)
    begin
        im_y = ir_addr / `kImageNoOfPixels;
        im_x = ir_addr - `kImageNoOfPixels * im_y;
        image_dump_pixel(im_x, im_y, ir_val);
    end
    if (ir_kick)
        image_dump_init();
    else if (ir_done)
        image_dump_finish();
end

endmodule
