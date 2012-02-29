from utils import enum

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
    reverse = '1'

class buff_step_mode(enum):
    tan = '0'
    cot = '1'

class buff_step_direction(enum):
    ascending = '0'
    descending = '1'

class processing_state_control_states(enum):
    def __init__(self):
        self.ready = None
        self.fill = None
        self.fill_done = None
        self.shift = None
        super(processing_state_control_states, self).__init__()

class shifter_states(enum):
    def __init__(self):
        self.ready = None
        self.fill = None
        self.fill_done = None
        self.shift = None
        super(shifter_states, self).__init__()

class mapper_states(enum):
    def __init__(self):
        self.ready = None
        self.mapping = None
        super(mapper_states, self).__init__()

class swap_control_states(enum):
    def __init__(self):
        self.ready = None
        self.setup = None
        self.fill = None
        self.fill_and_shift = None
        self.shift = None
        super(swap_control_states, self).__init__()

class filtered_ram_control_states(enum):
    def __init__(self):
        self.ready = None
        self.delay = None
        self.fill = None
        super(filtered_ram_control_states, self).__init__()

class filtered_ram_swap_control_states(enum):
    def __init__(self):
        self.ready = None
        self.fill = None
        self.fill_and_work = None
        self.work = None
        super(filtered_ram_swap_control_states, self).__init__()
