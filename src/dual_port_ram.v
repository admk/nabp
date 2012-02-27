{# include('templates/defines.v') #}
// NABPDualPortRAM
//     5 Feb 2012
// The RAM that stores the filtered projection data

module NABPDualPortRAM
(
    clk,
    {% for i in range(2) %}
        we_{#i#},
        addr_{#i#},
        data_in_{#i#},
        data_out_{#i#}
        {% if i != 1 %},{% end %}
    {% end %}
);

parameter pDataLength = {# c['kFilteredDataLength'] #};

// global signals
input wire clk;
{% for i in range(2) %}
// inputs for port {#i#}
input wire we_{#i#};
input wire [`kSLength-1:0] addr_{#i#};
input wire [pDataLength-1:0] data_in_{#i#};
// outputs for port {#i#}
output reg [pDataLength-1:0] data_out_{#i#};
{% end %}

reg [pDataLength-1:0] ram[`kProjectionLineSize-1:0];

{% for i in range(2) %}
always @(posedge clk)
begin:port_{#i#}_read_write
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
