from nabp_utils import enum

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
