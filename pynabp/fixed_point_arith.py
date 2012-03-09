from utils import dec2bin

class FixedPoint(object):
    """
    A simple fixed point arithmetic utility for generating
    fixed point arithmetic verilog source code
    """
    def __init__(
            self, integer_width, fractional_width,
            signed=False, value=None):
        self.integer_width = integer_width
        self.fractional_width = fractional_width
        self.signed = signed
        self.value = value if not value is None else 0

    def width(self):
        sign_bit = 1 if self.signed else 0
        return int(sign_bit + self.integer_width + self.fractional_width)

    def bin_repr(self):
        return self.bin_repr_of_value(self.value)

    def range(self):
        """
        >>> FixedPoint(4, 4, True).range()
        (-16.0, 15.9375)
        >>> FixedPoint(4, 4, False).range()
        (0.0, 15.9375)
        """
        if self.signed:
            min_val = -2 ** (self.width() - 1)
            max_val = 2 ** (self.width() - 1) - 1
        else:
            min_val = 0
            max_val = 2 ** self.width() - 1
        min_val /= float(2 ** self.fractional_width)
        max_val /= float(2 ** self.fractional_width)
        return (min_val, max_val)

    def precision(self):
        """
        >>> x = FixedPoint(4, 4, True, value='110011100')
        >>> y = FixedPoint(4, 4, True, value='110011101')
        >>> p = x.precision()
        >>> p
        0.0625
        >>> y.value - x.value == p
        True
        """
        return 1 / float(2 ** self.fractional_width)

    def possible_values_list(self):
        i, max_val = self.range()
        l = []
        while i < max_val:
            l.append(i)
            i += self.precision()
        l.append(i)
        return l

    def verilog_decl(self):
        """
        >>> FixedPoint(4, 4, True).verilog_decl()
        'signed [8:0]'
        """
        signed = 'signed ' if self.signed else ''
        return signed + '[' + str(self.width() - 1) + ':0]'

    def verilog_repr_decorator(self, func):
        def dec_func(*args):
            return self.verilog_repr(func(*args))
        return dec_func

    def verilog_repr(self, value=None):
        """
        >>> FixedPoint(4, 4, True, value='110011101').verilog_repr()
        "9'b110011101"
        >>> FixedPoint(4, 4, True, value=-6.37).verilog_repr()
        "9'b110011011"
        """
        repr_str = str(self.width()) + '\'b'
        if not value is None:
            return repr_str + self.bin_repr_of_value(value)
        return repr_str + self.bin_repr()

    def type_repr(self):
        signed_str = 'S' if self.signed else 'U'
        return signed_str + '(' + str(self.integer_width) + ').(' + \
                str(self.fractional_width) + ')'

    def verilog_floor_slice(self):
        """
        >>> FixedPoint(4, 6, True).verilog_floor_slice()
        '[10:6]'
        >>> FixedPoint(1, 3).verilog_floor_slice()
        '[3]'
        """
        from_slice = self.width() - 1
        to_slice = self.fractional_width
        if from_slice > to_slice:
            return '[' + str(from_slice) + ':' + str(to_slice) + ']'
        elif from_slice == to_slice:
            return '[' + str(from_slice) + ']'
        else:
            raise RuntimeError('Unexpected slicing problem encountered.')

    def verilog_floor_shift(self):
        return '>>> ' + str(self.fractional_width)

    def bin_repr_of_value(self, value):
        """
        >>> FixedPoint(4, 4, True).bin_repr_of_value(-6.1875)
        '110011110'
        """
        value *= 2 ** self.fractional_width
        return dec2bin(int(value + .5), self.width())

    def value_of_bin_repr(self, repr_str):
        """
        >>> FixedPoint(4, 4, True).value_of_bin_repr('000000000')
        0.0
        >>> FixedPoint(4, 4, True).value_of_bin_repr('000000001')
        0.0625
        >>> FixedPoint(4, 4, True).value_of_bin_repr('110011101')
        -6.1875
        """
        if self.width() != len(repr_str):
            raise ValueError(
                    'Length of repr_str (%d) and width (%d) mismatch.' %
                    (len(repr_str), self.width()))
        val = 0
        for idx in xrange(self.width()):
            acc = int(repr_str[idx]) * (2 ** (self.width() - idx - 1))
            if idx == 0 and self.signed:
                acc = -acc
            val += acc
        val /= float(2 ** self.fractional_width)
        return val

    @property
    def value(self):
        return self._value

    @value.setter
    def value(self, value):
        """
        >>> FixedPoint(4, 4, True, value=-6.37).value
        -6.3125
        """
        if type(value) is float or type(value) is int:
            value = self.value_of_bin_repr(
                    self.bin_repr_of_value(value))
        elif type(value) is str:
            value = self.value_of_bin_repr(value)
        else:
            raise TypeError(
                    'Expected a numer or a binary represenation.')
        if value < self.range()[0] or value > self.range()[1]:
            raise OverflowError(
                    'Value cannot be within the range of this representation.')
        self._value = value

    def __str__(self):
        """
        >>> FixedPoint(4, 4, True, value=-6.37)
        <FixedPoint: S(4).(4) = -6.3125>
        """
        return '<FixedPoint: %s = %s>' % (self.type_repr(), str(self.value))

    def __repr__(self):
        return self.__str__()

if __name__ == '__main__':
    import doctest
    doctest.testmod()
