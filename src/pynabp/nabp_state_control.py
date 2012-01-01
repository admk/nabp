import nabp_utils
class states:
    """
    >>> states.width
    2
    >>> print states.init
    2'd0
    """
    no = 4
    width = nabp_utils.bin_width_of_dec(no)
    init = str(width) + '\'d0'
    fill = str(width) + '\'d1'
    fill_shift = str(width) + '\'d2'
    stop = str(width) + '\'d3'

if __name__ == '__main__':
    import doctest
    doctest.testmod()
