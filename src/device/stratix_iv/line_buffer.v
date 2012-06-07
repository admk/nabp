{# include('templates/defines.v') #}
// line_buffer
//     9 Mar 2012
// The line buffer implementation for Straix IV

module line_buffer
(
    clk, reset_n, enable,
    shift_in, taps
);

parameter pNoTaps = `kNoOfPartitions;
parameter pTapsWidth = `kPartitionSize;
parameter pPtrLength = 0; // dummy parameter to mute compilation error
parameter pDataLength = `kFilteredDataLength;

input wire clk, reset_n, enable;
input wire [pDataLength-1:0] shift_in;
output wire [pDataLength*pNoTaps-1:0] taps;

reg signed [`kFilteredDataLength-1:0] tap_b1;
wire [pDataLength*(pNoTaps-1)-1:0] taps_tp;

always @(posedge clk)
    if (enable)
        tap_b1 <= shift_in;

assign taps = {taps_tp, tap_b1};

altshift_taps
#(
    .intended_device_family("{# c['device'] #}"),
    .number_of_taps(pNoTaps-1),
    .power_up_state("CLEARED"),
    .taps_distance(pTapsWidth),
    .width(pDataLength),
    .lpm_type("altshift_taps"),
    .lpm_hint("unused")
)
pe_line_buff
(
    .clken(enable),
    .clock(clk),
    .shiftin(tap_b1),
    .taps(taps_tp)
);

endmodule
