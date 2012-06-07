{# include('templates/defines.v') #}
// shift_register
//     11 Feb 2012
// A shift register for testing as an FIR filter

module shift_register
(
    clk,
    enable,
    val_in, val_out
);

parameter pDelay = `kFIRDelay;
parameter pPtrLength = `kFIRDelayLength;
parameter pDataLength = `kFilteredDataLength;

input wire clk, enable;
input wire [pDataLength-1:0] val_in;
output reg [pDataLength-1:0] val_out;

reg [pDataLength-1:0] data[pDelay-2:0];
reg [pPtrLength-1:0] ptr;
integer i;
always @(posedge clk)
begin:ptr_update
    if (enable)
    begin
        if (ptr == pDelay - 2)
            ptr <= {pPtrLength{1'd0}};
        else
            ptr <= ptr + 1;
        val_out <= data[ptr];
        data[ptr] <= val_in;
    end
end

endmodule
