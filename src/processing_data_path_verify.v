{# include('templates/info.v') #}
// NABPProcessingDataPathVerify
//     16 Feb 2012
// This module verifies the data path for processing swappables by posing as
// a filtered RAM and each processing element

{#
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec, dec_repr
    from pynabp.enums import scan_mode

    no_pes = conf()['partition_scheme']['no_of_partitions']
    partition_size = conf()['partition_scheme']['size']
    partition_size_len = bin_width_of_dec(partition_size)
    filtered_data_len = conf()['kFilteredDataLength']
    a_len = conf()['kAngleLength']
    p_line_size = conf()['projection_line_size']
    s_val_len = bin_width_of_dec(p_line_size)
    i_size = conf()['image_size']
    scan_max = i_size - 1

    angle_defines = dict(
            (k, v) for k, v in conf().iteritems() if 'kAngle' in k)
#}
{% for key, val in angle_defines.iteritems() %}
`define {# key #} {# val #} {% end %}

`define kNoOfPartitions {# no_pes #}
`define kPartitionSize {# partition_size #}
`define kPartitionSizeLength {# partition_size_len #}
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
    input wire tt_verify_kick,
    // ram side
    input wire [`kSLength-1:0] pv_s_val,
    output reg [`kFilteredDataLength-1:0] pv_val,
    // pe side
    input wire pe_en,
    input wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps
);

always @(posedge clk)
    // a simple preliminary test with values exactly equals to the s_val
    // also used to determine if the s_val provided is correct
    pv_val <= pv_s_val;

integer status;
initial
    @(status)
        if (status != 0)
            $finish_and_return(status);
initial
begin
    status = $pyeval("from math import cos, sin, radians");
    status = $pyeval(
            "def project(a, x, y):\n",
            "    a = radians(a)\n",
            "    x = x - {# i_size #}\n",
            "    y = y - {# i_size #}\n",
            "    s = -x * sin(a) + y * cos(a)\n",
            "    return s + {# p_line_size #}\n");
end

integer scan_itr, scan_end, scan_base;
integer line, x, y, angle, i;
reg [`kFilteredDataLength-1:0] tap_val_ori;
wire [`kFilteredDataLength-1:0] tap_val[`kNoOfPartitions-1:0];
// FIXME iverilog does not like part select in a for loop
{% for i in xrange(no_pes) %}
assign tap_val[{#i#}] = pe_taps[
        `kFilteredDataLength*{#i+1#}-1:`kFilteredDataLength*{#i#}];
{% end %}
reg scan_mode;
always
begin:verification
    @(posedge reset_n);
    @(negedge tt_verify_kick);
    if (tt_angle < `kAngle45 || tt_angle >= `kAngle135)
        scan_mode = {# scan_mode.x #};
    else
        scan_mode = {# scan_mode.y #};
    if (tt_angle < `kAngle90)
    begin
        scan_itr = 0;
        scan_end = {# scan_max #};
        scan_base = 1;
    end
    else
    begin
        scan_itr = {# scan_max #};
        scan_end = 0;
        scan_base = -1;
    end
    $display("Angle: %d", tt_angle);
    while (scan_itr != scan_end)
    begin
        // verify output for all PEs
        for (i = 0; i < `kNoOfPartitions; i = i + 1)
        begin
            line = tt_line_itr + i * `kPartitionSize;
            if (scan_mode == {# scan_mode.x #})
            begin
                x = scan_itr;
                y = line;
            end
            else
            begin
                x = line;
                y = scan_itr;
            end
            tap_val_ori = $pyeval(
                    "project(", tt_angle, ",", x, ",", y, ")");
            $display("Tap %d, Expected %d, Acutal %d",
                    i, tap_val_ori, tap_val[i]);
        end
        // next scan iteration
        @(posedge clk);
        if (pe_en)
            scan_itr = scan_itr + scan_base;
    end
end

endmodule
