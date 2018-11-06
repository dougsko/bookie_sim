#!/usr/local/bin/gnuplot -persist

set datafile separator ","
set title "Bankrolls Over Time"
set xlabel "Week"
set ylabel "Dollars"
plot for [col=1:11] "/tmp/bookie.csv" using 0:col with lines title columnhead

