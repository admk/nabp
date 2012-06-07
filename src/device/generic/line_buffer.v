{# include('templates/defines.v') #}
// line_buffer
//     15 Feb 2012
// The line buffer implementation for simulation purposes

module line_buffer
(
    clk, enable,
    shift_in, taps
);

parameter pNoTaps = `kNoOfPartitions;
parameter pTapsWidth = `kPartitionSize;
parameter pPtrLength = {# bin_width(c['partition_scheme']['size']) #};

parameter pDataLength = `kFilteredDataLength;

input wire clk, enable;
input wire [pDataLength-1:0] shift_in;
output wire [pDataLength*pNoTaps-1:0] taps;

reg signed [`kFilteredDataLength-1:0] tap_b1;
wire [pDataLength*(pNoTaps-1)-1:0] taps_tp;

always @(posedge clk)
    if (enable)
        tap_b1 <= shift_in;

assign taps = {taps_tp, tap_b1};

wire [pDataLength-1:0] gen_taps[pNoTaps-2:0];

genvar i;
generate
    for (i = 0; i < pNoTaps - 1; i = i + 1)
    begin:gen_taps_inst
        assign taps_tp[pDataLength*(i+1)-1:pDataLength*i] = gen_taps[i];
        shift_register
        #(
            .pDelayLength(pTapsWidth),
            .pPtrLength(pPtrLength),
            .pDataLength(pDataLength)
        )
        tap_sr
        (
            .clk(clk),
            .enable(enable),
            .val_in((i == 0) ? tap_b1 : gen_taps[i-1]),
            .val_out(gen_taps[i])
        );
    end
endgenerate

endmodule
