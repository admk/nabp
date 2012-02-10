{# from pynabp.conf import conf #}
// clock & reset generate
parameter clk_period = {# conf()['clock_period'] #};
reg clk, reset;
wire reset_n;
assign reset_n = !reset;

initial
begin:global_signal_generate
	clk = 1'b0; reset = 1'b1; #100;
	clk = 1'b1; #100; clk = 1'b0; #100;
	clk = 1'b1; #50; reset = 1'b0; #50;
	forever
	begin
		clk = 1'b0; #clk_period;
		clk = 1'b1; #clk_period;
	end
end
