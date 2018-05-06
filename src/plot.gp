set grid

set datafile separator ","
set autoscale fix

set key autotitle columnhead noenhanced
set key left top
set xlabel 'number of input rows'
set ylabel 'calculation duration'

set term pdf enhanced font "Times,8"

set title 'Vectorization comparison (Full)'
set output "results/plot_full.pdf"
plot for [n=2:7] input_file u 1:(column(n)) w lp ps 0.4

set title 'Vectorization comparison (No valarray)'
set output "results/plot_no_valarray.pdf"
plot for [n=2:5] input_file u 1:(column(n)) w lp ps 0.4

#pause -1
