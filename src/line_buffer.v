{# include('templates/defines.v') #}
// line_buffer
//     15 Feb 2012
// The line buffer implementation for simulation purposes

{#
    no_pes = conf()['partition_scheme']['no_of_partitions']
    delay_len = conf()['partition_scheme']['size']
#}

module line_buffer
(
    clk, clear, enable,
    shift_in, taps
);

parameter pNoTaps = {# no_pes - 1 #};
parameter pTapsWidth = {# delay_len #};
parameter pPtrLength = {# bin_width(delay_len) #};

parameter pDataLength = {# c['kFilteredDataLength'] #};

input wire clk, clear, enable;
input wire [pDataLength-1:0] shift_in;
output wire [pDataLength*pNoTaps-1:0] taps;

wire [pDataLength-1:0] gen_taps[pNoTaps-1:0];

genvar i;
generate
for (i = 0; i < pNoTaps; i = i + 1)
    begin:gen_taps_inst
        assign taps[pDataLength*(i+1)-1:pDataLength*i] = gen_taps[i];
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
            .clear(clear),
            .val_in((i == 0) ?  shift_in : gen_taps[i-1]),
            .val_out(gen_taps[i])
        );
    end
endgenerate

endmodule
