{# from pynabp.conf import conf #}
// clock & reset generate
parameter clk_period = {# conf()['clock_period'] #} / 2;
reg clk, reset;
wire reset_n;
assign reset_n = !reset;

always
begin:clk_generate
    clk = 1'b0; #clk_period;
    clk = 1'b1; #clk_period;
end

initial
begin:reset_generate
	reset = 1'b1;
	#(3.5*clk_period);
	reset = 1'b0;
end
