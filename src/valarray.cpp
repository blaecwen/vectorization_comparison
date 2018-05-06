
#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <err.h>
#include <time.h>

#include <iostream>
#include <valarray>

using namespace std;

#define ROWS_MULTIPLICITY 4

#define INPUT_FILE "data.txt"


int parse_args(int argc, char *argv[]) {
    if (argc != 2)
        errx(EXIT_FAILURE, "Invalid arguments\n\nRun:\n\t%s <rows_number>", argv[0]);

    char *endptr;
    int rows_number = strtol(argv[1], &endptr, 10);
    if (*endptr != '\0')
        errx(EXIT_FAILURE, "Invalid argument, expected integer, got: '%s'", argv[1]);

    if (rows_number % ROWS_MULTIPLICITY != 0)
        errx(EXIT_FAILURE, "Invalid argument, <rows_number> should be multiple of %d, but got: %d", ROWS_MULTIPLICITY, rows_number);

    return rows_number;
}


int read_file(const char* filename, valarray<int> *a, valarray<int> *b, valarray<int>* c, int length) {
    FILE *fp;
    fp = fopen(filename, "r");
    if (fp == NULL) {
        err(EXIT_FAILURE, "Error openning file '%s'", filename);
    }

    int ignore;
    for (int i = 0; i < length; i++) {
        a[i].resize(ROWS_MULTIPLICITY);
        b[i].resize(ROWS_MULTIPLICITY);
        c[i].resize(ROWS_MULTIPLICITY);
        for (int j = 0; j < ROWS_MULTIPLICITY; j++) {
            int rc = fscanf(fp, "%d %d %d %d", &ignore, &a[i][j], &b[i][j], &c[i][j]);
            if (rc == EOF && errno != 0) {
                warn("Warning: Error reading row #%d from file", i);
                return -1;
            }
            else if (rc != 4)  {
                warnx("Warning: Error reading row #%d from file (EOF?)", i);
                return -1;
            }
        }
    }
    fclose(fp);
    return length;
}


int run_calc(valarray<int> *a, valarray<int> *b, valarray<int> *c, int length) {
    valarray<int> *res = new valarray<int>[length];
    clock_t t1 = clock();
    for (int i = 0; i < length; i++) {
        res[i] = a[i] + b[i]*c[i];
    }
    clock_t t2 = clock();
    delete[] res;
    return t2 - t1;
}


int main(int argc, char *argv[]) {
    int rows_number = parse_args(argc, argv);
    printf("Rows: %d\n", rows_number);
    printf("File: %s\n", INPUT_FILE);

    rows_number /= 4;
    valarray<int> *a = new valarray<int>[rows_number];
    valarray<int> *b = new valarray<int>[rows_number];
    valarray<int> *c = new valarray<int>[rows_number];

    int rc = read_file(INPUT_FILE, a, b, c, rows_number);
    if (rc != rows_number)
        errx(EXIT_FAILURE, "Error reading file '%s': Unable to read %d rows", INPUT_FILE, rows_number);

    int time = run_calc(a, b, c, rows_number);
    printf("Time: %d\n", time);

    delete[] a;
    delete[] b;
    delete[] c;
}