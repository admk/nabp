{# from pynabp.conf import conf #}
// clock & reset generate
parameter clk_period = {# conf()['clock_period'] #} / 2;
parameter half_clk_period = clk_period / 2;
reg clk, reset;
wire reset_n;
assign reset_n = !reset;

initial
begin:global_signal_generate
	clk = 1'b0; reset = 1'b1; #clk_period;
	clk = 1'b1; #clk_period; clk = 1'b0; #clk_period;
	clk = 1'b1; #half_clk_period; reset = 1'b0; #half_clk_period;
	forever
	begin
		clk = 1'b0; #clk_period;
		clk = 1'b1; #clk_period;
	end
end
