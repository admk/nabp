import os
from akpytemp import Template
from akpytemp.template import code_gobble

from pynabp.fixed_point_arith import FixedPoint
from pynabp.conf_gen import config

translate_process_template = \
        r"""
        #!/usr/bin/env python
        import sys, os

        try:
            sys.path.append(os.path.abspath('.'))
            from pynabp.conf_gen import config
            fixed = config['{# fixed #}']
        except Exception as e:
            pass

        while True:
            val_str = raw_input()

            try:
                fixed.value = val_str
                val_str = str(fixed.value)
            except Exception as e:
                val_str += '!' + str(e).replace('\n', ' ')

            sys.stdout.write(val_str + '\n')
            sys.stdout.flush()
        """
translate_process_template = code_gobble(
        translate_process_template, gobble_count=None, eat_empty_lines=True)


def fixed_point_translate_filter_process_files():
    for k, v in config.iteritems():
        if type(v) is FixedPoint:
            yield k + '.pytf'

def write_translate_process(target):
    target_key = os.path.splitext(target)[0]
    target_key = os.path.split(target_key)[1]
    t = Template(template=translate_process_template)
    t.save(target, fixed=target_key, target=target)
    os.chmod(target, 0755)
