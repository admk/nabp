{# include('templates/defines.v') #}
// NABPProcessingDataPathVerify
//     16 Feb 2012
// This module verifies the data path for processing swappables by posing as
// a filtered RAM and each processing element

{#
    from pynabp.enums import scan_mode
    scan_max = c['image_size'] - 1
#}

module NABPProcessingDataPathVerify
(
    // global signals
    input wire clk,
    input wire reset_n,
    // host side
    input wire [`kAngleLength-1:0] tt_angle,
    input wire [`kPartitionSizeLength-1:0] tt_line_itr,
    // ram side
    {% for i in xrange(2) %}
    input wire [`kSLength-1:0] pv{#i#}_s_val,
    output reg [`kFilteredDataLength-1:0] pv{#i#}_val,
    {% end %}
    // pe side
    input wire pe_kick,
    input wire [`kFilteredDataLength*`kNoOfPartitions-1:0] pe_taps
);

parameter pSDifferenceTolerance = 0;
parameter pVerbose = 1;

always @(posedge clk)
begin
    // a simple preliminary test with values exactly equals to the s_val
    // also used to determine if the s_val provided is correct
    {% for i in xrange(2) %}
    pv{#i#}_val <= pv{#i#}_s_val;
    {% end %}
end

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
            "    x = x - {# c['image_center'] #}\n",
            "    y = y - {# c['image_center'] #}\n",
            "    s = -x * sin(a) + y * cos(a)\n",
            "    return int(s + {# c['projection_line_center'] #} + 0.5)\n");
end

reg [`kFilteredDataLength-1:0] tap_val_exp;
real s_val_exp;
function integer verify;
    input [`kFilteredDataLength-1:0] actual;
    input integer x;
    input integer y;
    integer diff;
    begin
        // FIXME: iverilog vpi does not like real values
        s_val_exp = $pyeval(
                "project(", tt_angle, ",", x, ",", y, ")");
        tap_val_exp = s_val_exp;
        diff = tap_val_exp - actual;
        verify = 1;
        if (diff < -pSDifferenceTolerance || diff > pSDifferenceTolerance)
        begin
            if (pVerbose)
                $display(
    "Line Itr %d, Scan Itr %d, Tap %d, Expected %d, Acutal %d, Diff %d",
                        tt_line_itr, scan_itr, i, tap_val_exp, actual, diff);
            verify = 0;
        end
    end
endfunction

// generate pe_en
reg [`kImageSizeLength-1:0] pe_scan_cnt;
assign pe_en = (pe_scan_cnt != {# to_i(0) #});
always @(posedge clk)
begin:deprecated_pe_en
    if (!reset_n)
        pe_scan_cnt <= {# to_i(0) #};
    else if (pe_kick)
        pe_scan_cnt <= {# to_i(c['image_size'] - 1) #};
    if (pe_en)
        pe_scan_cnt <= pe_scan_cnt - {# to_i(1) #};
end

integer scan_itr, scan_end, scan_base;
integer line, x, y, angle, i, v, verify_cnt, px_cnt;
real accuracy;
wire [`kFilteredDataLength-1:0] tap_val[`kNoOfPartitions-1:0];
wire [`kFilteredDataLength-1:0] tap_val0;
assign tap_val0 = pe_taps[`kFilteredDataLength-1:0];
// FIXME iverilog does not like part select in a for loop
{% for i in xrange(c['partition_scheme']['no_of_partitions']) %}
assign tap_val[{#i#}] = pe_taps[
        `kFilteredDataLength*{#i+1#}-1:`kFilteredDataLength*{#i#}];
{% end %}
reg scan_mode;
always
begin:pe_verify
    @(posedge pe_en); #1;
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
    $display("Angle: %d, Line Itr: %d", tt_angle, tt_line_itr);
    px_cnt = 0;
    verify_cnt = 0;
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
            v = verify(tap_val[i], x, y);
            if (v)
                verify_cnt = verify_cnt + 1;
            px_cnt = px_cnt + 1;
        end
        // next scan iteration
        @(posedge clk);
        if (pe_en)
            scan_itr = scan_itr + scan_base;
    end
    accuracy = 100 * $itor(verify_cnt) / px_cnt;
    $display("Verified %d, Total pixels %d, Accuracy %.2f%%",
            verify_cnt, px_cnt, accuracy);
end

endmodule
