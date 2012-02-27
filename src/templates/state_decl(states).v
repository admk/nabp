{#
    from pynabp.utils import dec_repr
#}
parameter [{# states.width - 1 #}:0] // synopsys enum code{#
  #}{% for idx, key in enumerate(states.enum_keys()) %}
        {# key #}_s = {# dec_repr(states.enum_dict()[key], states.width) #}{#
      #}{% if idx < len(states.enum_keys()) - 1 %},{% end %}{#
  #}{% end %};
// synopsys state_vector state
reg [{# states.width - 1 #}:0] // synopsys enum code
        state, next_state;
{#
    # write translate filter file
    with open(parent().target_path() + 'tf', 'w') as f:
        f.write('# gtkwave translate filter file for %s\n' % parent().name())
        for key, val in states.enum_dict().iteritems():
            f.write(str(val) + ' ' + str(key) + '_s\n')
#}
