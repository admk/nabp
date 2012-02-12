// dump all signals
initial
begin
    $dumpfile("build/{# parent.name() #}.vcd");
    $dumpvars(0);
end
