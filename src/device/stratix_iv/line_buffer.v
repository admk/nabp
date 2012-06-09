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

reg signed [pDataLength-1:0] tap_b1;

always @(posedge clk)
    if (enable)
        tap_b1 <= shift_in;

genvar i, j;
generate
    if (pNoTaps == 1)
    begin:gen_no_line_buff
        assign taps = tap_b1;
    end
    else
    begin:gen_line_buff
        wire [pDataLength*(pNoTaps-1)-1:0] taps_tp;
        assign taps = {taps_tp, tap_b1};
        if (pTapsWidth >= 3)
        begin:gen_altshift_taps
            altshift_taps
            #(
                .NUMBER_OF_TAPS(pNoTaps-1),
                .POWER_UP_STATE("DONT_CARE"),
                .TAP_DISTANCE(pTapsWidth),
                .WIDTH(pDataLength)
            )
            pe_line_buff
            (
                .clken(enable),
                .clock(clk),
                .shiftin(tap_b1),
                .taps(taps_tp)
            );
        end
        else
        begin:gen_reg_shift_taps
            reg [pDataLength-1:0] shift_regs[pNoTaps*pTapsWidth:0];
            always @(posedge clk)
                shift_regs[pTapsWidth] <= tap_b1;
            for (i = 1; i < pNoTaps; i = i + 1)
            begin:gen_taps
                assign taps_tp[pDataLength*i-1:pDataLength*(i-1)] =
                        shift_regs[(i+1)*pTapsWidth-1];
            end
            for (i = 1; i < pNoTaps; i = i + 1)
            begin:gen_shift_regs_outer
                for (j = 0; j < pTapsWidth; j = j + 1)
                begin:gen_shift_regs_update
                    always @(posedge clk)
                        shift_regs[i * pTapsWidth + j + 1] <=
                                shift_regs[i * pTapsWidth + j];
                end
            end
        end
    end
endgenerate

endmodule
