import math

def dec2bin(num, width=0):
    """
    >>> dec2bin(0, 8)
    '00000000'
    >>> dec2bin(57, 8)
    '00111001'
    >>> dec2bin(3, 10)
    '0000000011'
    >>> dec2bin(-23, 8)
    '11101001'
    >>> dec2bin(23, 8)
    '00010111'
    """
    if num < 0:
        if not width:
            raise ValueError('Width must be specified for negative numbers')
        num += 2 ** width
    binary = ''
    while num:
        if num & 1:
            binary += '1'
        else:
            binary += '0'
        num >>= 1
    if width:
        no_zeros = width - len(binary)
        if no_zeros < 0:
            raise OverflowError('A binary of width %d cannot fit %d' %
                    (width, num))
        binary += '0' * no_zeros
    if not binary:
        binary = '0'
    return binary[::-1]

def bin_width_of_dec(num):
    return int(math.ceil(math.log(num, 2)))

def dec_repr(num, width=0):
    if not width:
        width = bin_width_of_dec(num)
    return str(width) + '\'d' + str(int(num))

def bin_width_of_dec_vals(vals):
    min_val, max_val = min(vals), max(vals)
    width = bin_width_of_dec(max(max_val, abs(min_val)))
    if min_val < 0:
        signed = True
    else:
        signed = False
    return width, signed

def xfrange(start, stop, step=1):
    idx = start
    while idx < stop:
        yield idx
        idx += step
    else:
        return

class enum(object):
    def __init__(self):
        self.generate_states()

    def generate_states(self):
        keys = self.enum_keys()
        no = len(keys)
        width = bin_width_of_dec(no)
        for idx, key in enumerate(keys):
            self.__dict__[key] = '%d\'b%s' % (width, dec2bin(idx, width))
        self.no = no
        self.width = width
        return self

    def enum_dict(self):
        d = {}
        for k, v in self.__dict__.iteritems():
            if (type(v) is str or v is None) and \
                    not k.startswith('_'):
                d[k] = v
        return d

    def enum_keys(self):
        return self.enum_dict().keys()
