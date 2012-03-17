{# from pynabp.conf_gen import config #}
// clock & reset generate
parameter clk_delay = {# config['clock_period'] #} / 2;
reg clk, reset;
wire reset_n;
assign reset_n = !reset;

always
begin:clk_generate
    clk = 1'b0; #clk_delay;
    clk = 1'b1; #clk_delay;
end

initial
begin:reset_generate
    reset = 1'b1;
    #(3.5*clk_delay);
    reset = 1'b0;
end

// simulation time limit
integer clk_cnt;
initial
begin:clk_limit
    clk_cnt = 0;
    while (clk_cnt < 40000)
    begin
        @(posedge clk); 
        clk_cnt = clk_cnt + 1;
    end
    $finish;
end
