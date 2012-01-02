from utils import enum, bin_width_of_dec

class sector(enum):
    a = '2\'d0'
    b = '2\'d1'
    c = '2\'d2'
    d = '2\'d3'

class scan_mode(enum):
    x = '0'
    y = '1'

class scan_direction(enum):
    forward = '0'
    backward = '1'

class buff_step_mode(enum):
    tan = '0'
    cot = '1'

class buff_step_direction(enum):
    ascending = '0'
    descending = '1'

class state_control_states(enum):
    no = 6
    width = bin_width_of_dec(no)
    init = str(width) + '\'d0'
    setup = str(width) + '\'d1'
    fill = str(width) + '\'d2'
    fill_done = str(width) + '\'d3'
    shift = str(width) + '\'d4'
    shift_done = str(width) + '\'d5'

class shifter_states(enum):
    no = 4
    width = bin_width_of_dec(no)
    ready = str(width) + '\'d0'
    fill = str(width) + '\'d1'
    fill_done = str(width) + '\'d2'
    shift = str(width) + '\'d3'
