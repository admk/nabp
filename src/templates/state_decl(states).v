parameter [{# states.width - 1 #}:0] // synopsys enum code{#
  #}{% for idx, key in enumerate(states.enum_keys()) %}
        {# key #}_s = {# states.enum_dict()[key] #}{#
      #}{% if idx < len(states.enum_keys()) - 1 %},{% end %}{#
  #}{% end %};
// synopsys state_vector state
reg [{# states.width - 1 #}:0] // synopsys enum code
        state, next_state;
