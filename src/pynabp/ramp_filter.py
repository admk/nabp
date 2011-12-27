import numpy as np

def ramp_filter(order):
    """
    Coefficients for even ordered FIR ramp filter
    """
    # construct ramp filter in the frequency domain
    fr = np.linspace(0, 1, order / 2 + 1)
    fr = np.concatenate((fr, fr[-2:0:-1]))
    # real part from the response
    # imaginary part due to loss of precision
    fr = np.real(np.fft.ifftshift(np.fft.ifft(fr)))
    # normalise
    return fr / np.max(fr)
