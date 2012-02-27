{#
    include('_info.v')

    from pynabp.conf import conf
    from pynabp.utils import bin_width_of_dec as bin_width, dec_repr
    c = conf()

    def to_a(val):
        return dec_repr(val, c['kAngleLength'])
    def to_s(val):
        return dec_repr(val, bin_width(c['projection_line_size']))
    def to_l(val):
        return dec_repr(val, bin_width(c['partition_scheme']['size']))
    def to_v(val):
        return dec_repr(val, c['kFilteredDataLength'])
#}
`timescale 1ns/10ps

`define kAngleLength {# c['kAngleLength'] #}

`define kDataLength {# c['kDataLength'] #}
`define kFilteredDataLength {# c['kFilteredDataLength'] #}

`define kNoOfPartitions {# c['partition_scheme']['no_of_partitions'] #}
`define kNoOfPartitonsLength {#
            bin_width(c['partition_scheme']['no_of_partitions']) #}
`define kPartitionSize {# c['partition_scheme']['size'] #}
`define kPartitionSizeLength {#
            bin_width(c['partition_scheme']['size']) #}

`define kDelayLength {# c['filter']['order'] / 2 #}

`define kProjectionLineSize {# c['projection_line_size'] #}
`define kSLength {# bin_width(c['projection_line_size']) #}

`define kImageSizeLength {# bin_width(c['image_size']) #}

{# angle_defines = { k: v for k, v in c.iteritems() if 'kAngle' in k } #}
{% for key, val in angle_defines.iteritems() %}
`define {# key #} {# val #} {% end %}
