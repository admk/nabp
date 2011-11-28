%% Partitioning
function pe_set = nabp_partition(size, no_of_partitions)

    pe_set.no_of_partitions = no_of_partitions;
    assert(pe_set.no_of_partitions <= size, ...
        'Number of partitions must be less than image size');

    % initialise partitions array
    pe_set.partitions(pe_set.no_of_partitions) = struct('lower', -1, 'upper', -1);
    pe_set.partition_size = ceil(size / pe_set.no_of_partitions);
    for pe_partition_idx = 1:pe_set.no_of_partitions
        pe_range.lower = (pe_partition_idx - 1) * pe_set.partition_size + 1;
        pe_range.upper = pe_partition_idx * pe_set.partition_size;
        if pe_range.lower > size
            % current pe is out of range
            % ignore current out of range partition
            pe_set.no_of_partitions = pe_partition_idx - 1;
            % reshape partitions
            pe_set.partitions = pe_set.partitions(...
                    1:pe_set.no_of_partitions);
            break
        else
            % current pe in range
            pe_set.partitions(pe_partition_idx) = pe_range;
        end
    end
    % pe tap range match assertion
    last_tap = (pe_set.no_of_partitions - 1) * pe_set.partition_size + 1;
    assert(last_tap == pe_set.partitions(end).lower);
end
