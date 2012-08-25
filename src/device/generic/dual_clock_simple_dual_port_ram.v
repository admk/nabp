{# include('templates/defines.v') #}
// NABPDualClockSimpleDualPortRAM
//     5 Feb 2012
// A dual clock simple dual port RAM. Has a read port and a write port.

module NABPDualClockSimpleDualPortRAM
#(
    parameter pDataLength = `kFilteredDataLength,
    parameter pRAMSize = `kProjectionLineSize,
    parameter pAddrLength = `kSLength // log2(pRAMSize)
) (
    input wire clk_in,
    input wire clk_out,
    input wire we,
    input wire [pAddrLength-1:0] addr_in,
    input wire [pAddrLength-1:0] addr_out,
    input wire [pDataLength-1:0] data_in,
    output reg [pDataLength-1:0] data_out
);

reg [pDataLength-1:0] ram[pRAMSize-1:0];

{% if c['debug'] %}
// initialise RAM content to x
integer i;
initial
    for (i = 0; i < pRAMSize; i = i + 1)
        ram[i] <= 'dx;
{% end %}

always @(posedge clk_in)
begin:write_port_update
    if (we)
        ram[addr_in] <= data_in;
end

always @(posedge clk_out)
begin:read_port_update
    data_out <= ram[addr_out];
end

endmodule
