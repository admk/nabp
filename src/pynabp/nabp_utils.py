import math

class enum:
    @classmethod
    def enum_dict(cls):
        d = {}
        for k, v in cls.__dict__.iteritems():
            if type(v) is str and not k.startswith('_'):
                d[k] = v
        return d

    @classmethod
    def enum_keys(cls):
        """
        >>> enum.enum_keys()
        []
        >>> enum.__dict__['x'] = 'x'
        >>> enum.enum_keys()
        ['x']
        """
        return cls.enum_dict().keys()

def dec2bin(num, width=0):
    """
    >>> dec2bin(0, 8)
    '00000000'
    >>> dec2bin(57, 8)
    '00111001'
    >>> dec2bin(3, 10)
    '0000000011'
    """
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
        for _ in xrange(no_zeros):
            binary += '0'
    if not binary:
        binary = '0'
    return binary[::-1]

def bin_width_of_dec(num):
    return int(math.ceil(math.log(num, 2)))

def dec_repr(num, width=0):
    if not width:
        width = bin_width_of_dec(num)
    return str(width) + '\'d' + str(num)

if __name__ == '__main__':
    import doctest
    doctest.testmod()
