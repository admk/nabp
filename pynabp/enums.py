from utils import enum


class scan_mode(enum):
    x = '0'
    y = '1'


class scan_direction(enum):
    forward = '0'
    reverse = '1'


class processing_element_states(enum):
    def __init__(self):
        self.ready = None
        self.work = None
        self.work_wait = None
        self.domino_start = None
        self.domino_0 = None
        self.domino_1 = None
        self.domino_finish = None
        super(processing_element_states, self).__init__()


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


class processing_swap_control_states(enum):
    def __init__(self):
        self.ready = None
        self.setup_1 = None
        self.setup_2 = None
        self.setup_3 = None
        self.fill = None
        self.angle_setup_1 = None
        self.angle_setup_2 = None
        self.angle_setup_3 = None
        self.fill_and_shift = None
        self.diverged_fill_and_shift = None
        self.shift = None
        super(processing_swap_control_states, self).__init__()


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
        self.diverged_work = None
        self.work = None
        super(filtered_ram_swap_control_states, self).__init__()


class image_addresser_states(enum):
    def __init__(self):
        self.ready = None
        self.delay = None
        self.addressing_x = None
        self.addressing_y = None


class sinogram_addresser_states(enum):
    def __init__(self):
        self.ready = None
        self.work = None
        super(sinogram_addresser_states, self).__init__()
