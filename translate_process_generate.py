import os
from akpytemp import Template
from akpytemp.template import code_gobble

translate_process_template = code_gobble(
        """
        #!/usr/bin/env python
        # dirty hack for minimal code size
        import sys
        sys.path.append('../src/')
        from pynabp.conf import conf
        fixed = conf['{# fixed #}']
        while True:
            try:
                fixed.value = int(raw_input())
                val = fixed.value
            except:
                val = '?'
            sys.stdout.write(val)
            sys.stdout.flush()
        """)

def write_translate_process(target):
    target_key = os.path.splitext(target)[0]
    target_key = os.path.split(target_key)[1]
    t = Template(template=translate_process_template)
    t.save(target, fixed=target_key)
