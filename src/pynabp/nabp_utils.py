import math

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

if __name__ == '__main__':
    import doctest
    doctest.testmod()
