{# include('templates/info.v') #}
// shift_register
//     11 Feb 2012
// A shift register for testing as an FIR filter
{#
    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec, dec_repr
    filtered_data_len = conf()['kFilteredDataLength']
    delay = conf()['filter']['order'] / 2
    delay_len = bin_width_of_dec(delay)
#}

module shift_register
(
    clk, reset_n,
    enable, clear,
    val_in, val_out
);

parameter pDelayLength = {# delay #};
parameter pPtrLength = {# delay_len #};
parameter pDataLength = {# filtered_data_len #};

input wire clk, reset_n, enable, clear;
input wire [pDataLength-1:0] val_in;
output reg [pDataLength-1:0] val_out;

reg [pDataLength-1:0] data[pDelayLength-2:0];
reg [pPtrLength-1:0] ptr;
integer i;
always @(posedge clk)
begin:ptr_update
    if (clear)
    begin
        ptr <= {pPtrLength{1'd0}};
        for(i = 0; i < pDelayLength; i = i + 1)
            data[i] <= {pPtrLength{1'd0}};
    end
    else if (enable)
    begin
        if (ptr == pDelayLength - 2)
            ptr <= {pPtrLength{1'd0}};
        else
            ptr <= ptr + 1;
        val_out <= data[ptr];
        data[ptr] <= val_in;
    end
end

endmodule
