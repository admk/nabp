{#
    include('_info.v')

    from pynabp.conf_gen import config as c
    from pynabp.utils import bin_width_of_dec as bin_width, dec_repr

    def to_a(val):
        return dec_repr(val, c['kAngleLength'])
    def to_s(val):
        return dec_repr(val, bin_width(c['projection_line_size']))
    def to_l(val):
        return dec_repr(val, bin_width(c['partition_scheme']['size']))
    def to_i(val):
        return dec_repr(val, bin_width(c['image_size']))
    def to_v(val):
        return dec_repr(val, c['kFilteredDataLength'])

    __angle_defines = { k: v for k, v in c.iteritems() if 'kAngle' in k }
#}
`timescale 1ns/{# c['time_precision'] #}

{% for key, val in __angle_defines.iteritems() %}
`define {# key #} {# val #} {% end %}

`define kDataLength {# c['kDataLength'] #}
`define kFilteredDataLength {# c['kFilteredDataLength'] #}

`define kNoOfPartitions {# c['partition_scheme']['no_of_partitions'] #}
`define kNoOfPartitonsLength {#
            bin_width(c['partition_scheme']['no_of_partitions']) #}
`define kPartitionSize {# c['partition_scheme']['size'] #}
`define kPartitionSizeLength {#
            bin_width(c['partition_scheme']['size']) #}

`define kDelayLength {# c['fir_order'] / 2 #}

`define kProjectionLineSize {# c['projection_line_size'] #}
`define kSLength {# bin_width(c['projection_line_size']) #}

`define kImageSizeLength {# bin_width(c['image_size']) #}

`define kAngleStep {# c['kAngleStep'] #}
`define kNoOfAngles {# c['no_of_angles'] #}
`define kNoOfAnglesLength {# bin_width(c['no_of_angles']) #}
`define kSinogramAddressLength {#
            bin_width(c['no_of_angles'] * c['projection_line_size'] - 1) #}
