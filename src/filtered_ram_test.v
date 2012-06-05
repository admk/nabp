{# include('templates/defines.v') #}
// NABPFilteredRAMTest
//     9 Feb 2012
// Tests functionality of the NABPFilteredRAMSwapControl

module NABPFilteredRAMTest();

{#
    include('templates/python_path_update.v')
    include('templates/global_signal_generate.v')
    include('templates/dump_wave.v')
    include('templates/data_test_vals.v')
#}

// angle value generator
wire hs_next_angle, hs_next_angle_ack, hs_has_next_angle;
wire [`kAngleLength-1:0] hs_angle;
hs_angles angles_generate
(
    .clk(clk),
    .reset_n(reset_n),
    .hs_next_angle(hs_next_angle),
    .hs_next_angle_ack(hs_next_angle_ack),
    .hs_angle(hs_angle),
    .hs_has_next_angle(hs_has_next_angle)
);

wire [`kSLength-1:0] hs_s_val;
wire [`kFilteredDataLength-1:0] filter_out;
wire [`kDataLength-1:0] filter_in;
assign filter_in = data_test_vals(hs_s_val, hs_angle);
NABPFilter filter
(
    .clk(clk),
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
            while (pr_s_val < {# to_s(c['projection_line_size']) #})
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
        begin
            @(posedge clk);
            @(posedge clk);
        	$finish;
        end
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
    .pr1_s_val(0 /* not used */),
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
