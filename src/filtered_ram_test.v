{# include('templates/info.v') #}
// NABPFilteredRAMTest
//     9 Feb 2012
// Tests functionality of the NABPFilteredRAMSwapControl
{#
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec, dec_repr
    data_len = conf()['kDataLength']
    filtered_data_len = conf()['kFilteredDataLength']
    a_len = conf()['kAngleLength']
    s_val_len = bin_width_of_dec(conf()['projection_line_size'])

    def to_a(val):
        return dec_repr(val, a_len)
    def to_s(val):
        return dec_repr(val, s_val_len)
    def to_v(val):
        return dec_repr(val, filtered_data_len)
#}
`define kAngleLength {# a_len #}
`define kSLength {# s_val_len #}
`define kDataLength {# data_len #}
`define kFilteredDataLength {# filtered_data_len #}
`define kDelayLength {# conf()['filter']['order'] / 2 #}

module NABPFilteredRAMTest();

{# include('templates/global_signal_generate.v') #}

// outputs to UUT
reg [`kAngleLength-1:0] hs_angle;
reg hs_has_next_angle;
// inputs from UUT
wire hs_next_angle, hs_next_angle_ack;
assign hs_next_angle_ack = hs_next_angle;
initial
begin:hs_angle_iterate
    @(posedge reset_n);
    hs_angle = {# to_a(0) #};
    hs_has_next_angle = 1;
    while (hs_angle <= {# to_a(80) #})
    begin
        @(posedge hs_next_angle_ack);
        if (hs_angle = {# to_a(80) #})
            hs_has_next_angle = 0;
        @(negedge hs_next_angle_ack);
        hs_angle = hs_angle + {# to_a(20) #};
    end
    @(posedge hs_next_angle);
    $finish;
end

function signed [`kFilteredDataLength-1:0] data_test_vals;
    input [`kSLength-1:0] s;
    input [`kAngleLength-1:0] a;
    begin
        // a simple function to generate a hash value
        data_test_vals = s + a;
    end
endfunction

wire [`kSLength-1:0] hs_s_val;
reg[`kFilteredDataLength-1:0] val_out;
always @(posedge clk)
begin:hs_look_up
    val_out <= data_test_vals(hs_s_val, hs_angle);
end

// FIFO to model filtering
`define kDelayDataLength `kFilteredDataLength*`kDelayLength
wire filter_enable, filter_clear;
assign filter_enable = 1;
assign filter_clear = hs_next_angle;
reg [`kDelayDataLength-1:0] filter_data;
wire [`kFilteredDataLength-1:0] filter_in, filter_out;
assign filter_in = val_out;
assign filter_out = filter_data[
            `kDelayDataLength-1:
            `kFilteredDataLength*(`kDelayLength-1)];
always @(posedge clk)
begin:filter
    if (filter_enable)
        filter_data[`kDelayDataLength-1:`kFilteredDataLength]
                <= {filter_data[`kFilteredDataLength*(`kDelayLength-1)-1:0],
                    filter_in};
    if (filter_clear)
        filter_data <= `kDelayDataLength'd0;
end

// processing model, verifies output
reg pr_next_angle;
wire pr_next_angle_ack;
wire [`kAngleLength-1:0] pr_angle;
reg [`kFilteredDataLength-1:0] pr_val_ori;
reg [`kSLength-1:0] pr_s_val;
wire [`kFilteredDataLength-1:0] pr_val;
always
begin:pr_verification
    pr_next_angle = 1;
    @(pr_next_angle_ack);
    if (pr_next_angle_ack)
    begin
        @(posedge clk);
        pr_next_angle = 0;
        pr_s_val = 0;
        while (pr_s_val < {# to_s(conf()['projection_line_size']) #})
        begin
            @(posedge clk);
            pr_val_ori = data_test_vals(pr_s_val, pr_angle);
            $display("Angle %d, S iteration: %d", pr_angle, pr_s_val);
            $display("Expected: %d, Found: %d", pr_val_ori, pr_val);
            pr_s_val = pr_s_val + 1;
        end
    end
end

// unit under test
NABPFilteredRAMSwapControl filtered_ram_swap_control_uut
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // inputs from host
    .hs_angle(hs_angle),
    .hs_has_next_angle(hs_has_next_angle),
    .hs_next_angle_ack(hs_next_angle_ack),
    // input from filter
    .hs_val(filter_out),
    // inputs from processing swappables
    .pr0_s_val(pr_s_val),
    .pr1_s_val(/* not used */),
    .pr_next_angle(pr_next_angle),
    // outputs to host RAM
    .hs_s_val(hs_s_val),
    .hs_next_angle(hs_next_angle),
    // outputs to processing swappables
    .pr_angle(pr_angle),
    .pr_next_angle_ack(pr_next_angle_ack),
    .pr0_val(pr_val),
    .pr1_val(/* not used */)
);

endmodule
