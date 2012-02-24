{#
    from pynabp.conf import conf
    pp_conf_excludes = ['lut', 'filter']
    pp_conf = []
    for k, v in conf().iteritems():
        spoil = False
        for exclude in pp_conf_excludes:
            if exclude in k:
                spoil = True
                break
        if not spoil:
            pp_conf.append((k, v))

    def escape(string):
        string = string.replace(r'"', r'\"');
        string = string.replace('\n', r'\n');
        return '\'\'\'' + string + '\'\'\''
#}
// dump config
integer dump_status;
initial
begin
    dump_status = $pyeval("from pprint import pprint");
    {% for k, v in pp_conf %}
    dump_status = $pyeval("pprint({# escape(repr((k, v))) #})");{% end %}
end
// dump all signals
initial
begin
    $dumpfile("build/{# parent.name() #}.lxt");
    $dumpvars(0);
end
