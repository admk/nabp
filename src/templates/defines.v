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
    def to_p(val):
        return dec_repr(val,
                bin_width(c['partition_scheme']['no_of_partitions']))
    def to_b(val):
        return '`YES' if val else '`NO'

    __angle_defines = { k: v for k, v in c.iteritems() if 'kAngle' in k }
#}
`timescale 1ns/{# c['time_precision'] #}

`define YES 1'b1
`define NO 1'b0

{% for key, val in __angle_defines.iteritems() %}
`define {# key #} {# val #} {% end %}

`define kDataLength {# c['kDataLength'] #}
`define kFilteredDataLength {# c['kFilteredDataLength'] #}
`define kCacheDataLength {#
            c['kFilteredDataLength'] + bin_width(c['kNoOfAngles']) #}

`define kNoOfPartitions {# c['partition_scheme']['no_of_partitions'] #}
`define kNoOfPartitonsLength {#
            bin_width(c['partition_scheme']['no_of_partitions']) #}
`define kPartitionSize {# c['partition_scheme']['size'] #}
`define kPartitionSizeLength {#
            bin_width(c['partition_scheme']['size']) #}

`define kFIRDelay {# c['fir_order'] / 2 #}
`define kFIRDelayLength {# bin_width(c['fir_order'] / 2) #}

`define kProjectionLineSize {# c['projection_line_size'] #}
`define kSLength {# bin_width(c['projection_line_size']) #}

`define kImageSizeLength {# bin_width(c['image_size']) #}
`define kImageNoOfPixels {# c['image_size'] ** 2 #}
`define kImageAddressLength {# bin_width(c['image_size'] ** 2) #}

`define kNoOfAngles {# c['kNoOfAngles'] #}
`define kNoOfAnglesLength {# bin_width(c['kNoOfAngles']) #}
`define kSinogramAddressLength {#
            bin_width(c['kNoOfAngles'] * c['projection_line_size'] - 1) #}
