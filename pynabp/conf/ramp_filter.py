import numpy as np

def ramp_filter(order):
    """
    Coefficients for even ordered FIR ramp filter
    """
    if order % 2 == 1:
        raise ValueError('Order is not an even number.')
    # construct ramp filter in the frequency domain
    fr = np.linspace(0, 1, order / 2 + 1)
    fr = np.concatenate((fr, fr[-2:0:-1]))
    # real part from the response
    # imaginary part due to loss of precision
    fr = np.real(np.fft.ifftshift(np.fft.ifft(fr)))
    # normalise
    return list(fr / np.max(fr))

if __name__ == '__main__':
    print ramp_filter(64)
