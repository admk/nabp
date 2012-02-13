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
{# include('templates/dump_wave.v') #}

// outputs to UUT
reg [`kAngleLength-1:0] hs_angle;
wire hs_has_next_angle;
// inputs from UUT
wire hs_next_angle, hs_next_angle_ack;
assign hs_next_angle_ack = hs_has_next_angle && hs_next_angle;
assign hs_has_next_angle = (hs_angle < {# to_a(80) #});
initial
begin:hs_angle_iterate
    hs_angle = {# to_a(0) #};
    @(posedge reset_n);
    while (hs_has_next_angle)
    begin
        @(negedge hs_next_angle_ack);
        hs_angle = hs_angle + {# to_a(20) #};
    end
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
wire [`kFilteredDataLength-1:0] filter_out, filter_in;
assign filter_in = data_test_vals(hs_s_val, hs_angle);
// shift register to model filtering
shift_register sr_filter_model
(
    .clk(clk),
    .reset_n(reset_n),
    .enable(1'd1), 
    .clear(hs_next_angle),
    .val_in(filter_in),
    .val_out(filter_out)
);

// processing model, verifies output
reg pr_next_angle;
reg pr_finish_next_round;
wire pr_next_angle_ack;
wire [`kAngleLength-1:0] pr_angle;
reg [`kFilteredDataLength-1:0] pr_val_ori;
reg [`kSLength-1:0] pr_s_val;
wire [`kFilteredDataLength-1:0] pr_val;
reg pr_test;
initial
begin:pr_verification
    pr_finish_next_round = 0;
    forever
    begin
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
                #1; // to make sure pr_s_val is updated
                pr_test = (pr_val != pr_val_ori);
                if (pr_test != 0)
                    $display(
                            "Error: S Val: %d, Expected: %d, Found: %d",
                            pr_s_val, pr_val_ori, pr_val);
                pr_s_val = pr_s_val + 1;
            end
            $display("Test RAM for Angle %d...Done", pr_angle);
            pr_s_val = `kSLength'bx;
        end
        if (pr_finish_next_round)
        	$finish;
        if (!hs_has_next_angle)
            pr_finish_next_round = 1;
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
