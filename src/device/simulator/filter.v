{# include('templates/defines.v') #}
// NABPFilter
module NABPFilter
(
    // global signals
    input wire clk,
    input wire reset_n,
    // filter control
    input wire enable,
    // filter data
    input wire [`kDataLength-1:0] val_in,
    output wire [`kFilteredDataLength-1:0] val_out
);

// pad val_in
wire [`kFilteredDataLength-1:0] filter_val_in;
assign filter_val_in = $signed(val_in);

// shift register to model filtering
// this is simply no filtering but a group delay
shift_register
#(
    .pDelay(`kFIRDelay),
    .pPtrLength(`kFIRDelayLength),
    .pDataLength(`kFilteredDataLength)
)
fake_filter
(
    .clk(clk),
    .reset_n(reset_n),
    .enable(enable),
    .val_in(filter_val_in),
    .val_out(val_out)
);

endmodule
