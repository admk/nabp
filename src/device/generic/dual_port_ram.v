{# include('templates/defines.v') #}
// NABPDualPortRAM
//     5 Feb 2012
// A simple dual port RAM. Preferably use it for simulation only, as Altera
// tools could give a less efficient RAM with extra logic around the RAM.

module NABPDualPortRAM
(
    clk,
    clear,
    {% for i in range(2) %}
        we_{#i#},
        addr_{#i#},
        data_in_{#i#},
        data_out_{#i#}
        {% if i != 1 %},{% end %}
    {% end %}
);

parameter pDataLength = `kFilteredDataLength;
parameter pRAMSize = `kProjectionLineSize;
parameter pAddrLength = `kSLength; // log2(pRAMSize)

// global signals
input wire clk, clear;
{% for i in range(2) %}
// inputs for port {#i#}
input wire we_{#i#};
input wire [pAddrLength-1:0] addr_{#i#};
input wire [pDataLength-1:0] data_in_{#i#};
// outputs for port {#i#}
output reg [pDataLength-1:0] data_out_{#i#};
{% end %}

reg [pDataLength-1:0] ram[pRAMSize-1:0];

integer i;
{% for i in range(2) %}
always @(posedge clk)
begin:port_{#i#}_read_write
    if (clear)
    begin
        ram[addr_{#i#}] <= {pDataLength{1'd0}};
        for(i = 0; i < pRAMSize; i = i + 1)
            ram[i] <= {pDataLength{1'd0}};
    end
    if (we_{#i#})
    begin
        ram[addr_{#i#}] <= data_in_{#i#};
        data_out_{#i#} <= data_in_{#i#};
    end
    else
        data_out_{#i#} <= ram[addr_{#i#}];
end
{% end %}

endmodule
