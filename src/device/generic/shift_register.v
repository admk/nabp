{# include('templates/defines.v') #}
// shift_register
//     11 Feb 2012
// A shift register for testing as an FIR filter

module shift_register
(
    clk,
    reset_n,
    enable,
    val_in, val_out
);

parameter pDelay = `kFIRDelay;
parameter pPtrLength = `kFIRDelayLength;
parameter pDataLength = `kFilteredDataLength;

input wire clk, reset_n, enable;
input wire [pDataLength-1:0] val_in;
output reg [pDataLength-1:0] val_out;

generate
if (pDelay < 1)
begin:pDelay_assert
    initial
    begin
        $display("pDelay is less than 1.");
        $finish();
    end
end
else if (pDelay == 1)
begin:sync_reg_gen
    // register
    always @(posedge clk)
    begin:sync_reg_update
        if (!reset_n)
            val_out <= {pDataLength{1'd0}};
        else if (enable)
            val_out <= val_in;
    end
end
else if (pDelay > 1)
begin:shift_reg_gen
    reg [pDataLength-1:0] data[pDelay-2:0];
    reg [pPtrLength-1:0] ptr;
    // shift register
    always @(posedge clk)
    begin:ptr_update
        if (!reset_n)
            ptr <= {pPtrLength{1'd0}};
        else if (enable)
        begin
            if (ptr == pDelay - 2)
                ptr <= {pPtrLength{1'd0}};
            else
                ptr <= ptr + 1;
            val_out <= data[ptr];
            data[ptr] <= val_in;
        end
    end
end
endgenerate

endmodule
