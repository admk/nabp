{#
    pp_conf_excludes = ['lut', 'coefs']
#}
// dump config
integer dump_status;
initial
begin
    python_path_update();
    dump_status = $pyeval("from pynabp.conf_gen import config");
    dump_status = $pyeval("from pprint import pprint");
    dump_status = $pyeval(
        "for (k, v) in config.iteritems():\n",
        "    p = True\n",
        "    for e in {# pp_conf_excludes #}:\n",
        "        if e in k: p = False\n",
        "    if p: pprint((k, v))");
end
// dump all signals
initial
begin
    $dumpfile("build/{# parent().name() #}.lxt");
    $dumpvars(0);
end
