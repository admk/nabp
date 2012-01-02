import utils

class states(utils.enum):
    no = 6
    width = utils.bin_width_of_dec(no)
    init = str(width) + '\'d0'
    setup = str(width) + '\'d1'
    fill = str(width) + '\'d2'
    fill_done = str(width) + '\'d3'
    shift = str(width) + '\'d4'
    shift_done = str(width) + '\'d5'
