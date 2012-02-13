// dump all signals
initial
begin
    $dumpfile("build/{# parent.name() #}.lxt");
    $dumpvars(0);
end
