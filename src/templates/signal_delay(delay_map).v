// S̲i̲g̲n̲a̲l̲ ̲d̲e̲l̲a̲y̲e̲r̲ ̲t̲e̲m̲p̲l̲a̲t̲e̲
//     {# name() #}
//
// The signals must be assigned to the version with _l suffix, e.g.
// assign signal_0_l = < your expression here >;
// and the output signal_0 will be the delayed version, with the number of
// cycles specified in delay_map.
{# 
    def var_name(base, delay):
        return base + '_' + str(delay)
#}
// Signals being delayed with number of delay cycles are -
//      {# delay_map #}.
{% for var, (var_decl, var_delay) in delay_map.iteritems() %}
    {% for delay in xrange(var_delay + 1) %}
        // declaration
        {% if delay == var_delay %}
            wire {# var_decl #} {# var #}_l, {# var_name(var, delay) #};
            assign {# var_name(var, delay) #} = {# var #}_l;
        {% else %}
            reg {# var_decl #} {# var_name(var, delay) #};
        {% end %}
        {% if delay > 0 %}
            always @(posedge clk)
                {# var_name(var, delay - 1) #} <= {# var_name(var, delay) #};
        {% end %}
    {% else %}
        assign {# var #} = {# var_name(var, 0) #};
    {% end %}
{% end %}
