#!/usr/bin/python3

import sys
import random

A_RANGE = (-100000, 100000)
B_RANGE = (-100000, 100000)
C_RANGE = (-100000, 100000)


if len(sys.argv) != 4:
    print("Invalid arguments")
    print()
    print("Run:")
    print("\t%s <output_file> <rows_number> <random_seed>" % sys.argv[0])
    exit(1)

out_filename = sys.argv[1]
rows_number = int(sys.argv[2])
random_seed = int(sys.argv[3])

random.seed(random_seed)

with open(out_filename, "w") as f:
    for i in range(rows_number):
        a = random.randrange(A_RANGE[0], A_RANGE[1])
        b = random.randrange(B_RANGE[0], B_RANGE[1])
        c = random.randrange(C_RANGE[0], C_RANGE[1])
        f.write("%d %d %d %d\n" % (i, a, b ,c))

print('Successfully generated %d rows to file "%s"' % (rows_number, out_filename))
