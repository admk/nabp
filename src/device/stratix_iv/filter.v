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
wire signed [`kDataLength:0] filter_val_in;
assign filter_val_in = {1'd0, val_in};

// actual filter
fir_ramp filter
(
    // global signals
    .clk(clk),
    .reset_n(reset_n),
    // filter inputs
    .ast_sink_data(filter_val_in),
    .ast_sink_valid(1'b1),
    .ast_source_ready(1'b1),
    .ast_sink_error(2'b00),
    // filter outputs
    .ast_source_data(val_out),
    .ast_sink_ready(),
    .ast_source_valid(),
    .ast_source_error()
);

endmodule
