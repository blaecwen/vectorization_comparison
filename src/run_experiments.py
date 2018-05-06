#!/usr/bin/python3

import collections
import csv
import sys
import subprocess
import os.path
import statistics


BINDIR = "bin"
BINARIES = ["gcc_vector", "gcc_vector_o3", "normal", "normal_o3", "valarray", "valarray_o3"]
# BINARIES = ["normal_o3"]


def profile(binary, row_counts, probes_number):
    print("Running", binary)
    binary_file = os.path.join(BINDIR, binary)

    times = list()
    for rn in row_counts:
        probes = list()

        for i in range(probes_number):
            rc = subprocess.check_output([binary_file, str(rn)])
            tm = int(rc.splitlines()[2].split()[1])
            probes.append(tm)

        times.append(statistics.mean(probes))
    return times


def main():
    if len(sys.argv) != 6:
        print("Invalid arguments")
        print()
        print("Run:")
        print("\t%s <output_file> <range_begin> <step> <steps_number> <probes>" % sys.argv[0])
        exit(1)

    out_filename = sys.argv[1]
    range_begin = int(sys.argv[2])
    step = int(sys.argv[3])
    steps_number = int(sys.argv[4])
    probes = int(sys.argv[5])

    res = collections.OrderedDict()
    res["ROWS"] = [x for x in range(range_begin, range_begin + step * steps_number, step)]
    for b in BINARIES:
        res[b] = profile(b, res["ROWS"], probes)
        print("\t", res[b])

    with open(out_filename, 'w', newline='') as f:
        writer = csv.writer(f)
        writer.writerow(["ROWS"] + BINARIES)
        writer.writerows(list(zip(*res.values())))

    print()
    print("Result was written to CSV file '%s'" % out_filename)

if __name__ == '__main__':
    main()
