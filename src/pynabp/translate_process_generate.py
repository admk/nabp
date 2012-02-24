from fixed_point_arith import FixedPoint
from akpytemp.template import code_gobble
import conf

translate_process_template = code_gobble(
        """
        #!/usr/bin/env python
        # dirty hack for minimal code size
        sys.path.append('../src/')
        import sys
        from pynabp.conf import conf
        fixed = conf['{# fixed_key #}']
        while True:
            fixed.value = int(raw_input())
            sys.stdout.write(fixed.value)
            sys.stdout.flush()
        """)

if __name__ == '__main__':
    # TODO implement translate process generation
    pass
