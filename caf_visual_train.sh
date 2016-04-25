#! /bin/zsh

LOG_FILE=log.txt
DATA_FILE=data.txt

~/caffe/build/tools/caffe train --solver=solver.prototxt 2>&1 | tee $LOG_FILE
data=`cat log.txt | grep 'Test net'`
test_interval=`cat log.txt | grep 'test_interval' | awk -F ':' '{print $2}' | sed 's/[[:space:]]//g'`
max_iter=`cat log.txt | grep 'max_iter' | awk -F ':' '{print $2}' | sed 's/[[:space:]]//g'`
data=`echo $data | awk -F '(' '{print $1}' | awk -F '=' '{print $2}' | sed 's/[[:space:]]//g'`
echo $data | awk -v interval=$test_interval -F '\n' 'BEGIN {i=0;} {name[i]=$1;i++;}; END{for (count=0;count<NR;count++) if (count%2==0) {printf count / 2 * interval "\t" name[count] "\t"} else {printf name[count] "\n"}}' 2>&1 | tee $DATA_FILE

let x_upper=$max_iter/$test_interval
x_upper=$x_upper*$test_interval

GNU_FILE=curve.gnu
echo "set term post eps color enhanced" > $GNU_FILE
echo 'set title "caffe loss-accuracy"' >> $GNU_FILE
echo 'set output "curve.eps"' >> $GNU_FILE
echo 'set size 1, 1' >> $GNU_FILE
echo 'set xlabel "iteration"' >> $GNU_FILE
echo "set xrange [0: $x_upper]" >> $GNU_FILE
echo "set x2range [0: $x_upper]" >> $GNU_FILE
echo 'set yrange [0:8]' >> $GNU_FILE
echo 'set ylabel "loss"' >> $GNU_FILE
echo 'set y2label "accuracy"' >> $GNU_FILE
echo 'set y2range [0:1]' >> $GNU_FILE
echo 'set ytics nomirror' >> $GNU_FILE
echo 'set xtics nomirror' >> $GNU_FILE
echo 'set y2tics' >> $GNU_FILE
echo 'set tics out' >> $GNU_FILE
echo 'set autoscale y' >> $GNU_FILE
echo 'set autoscale y2' >> $GNU_FILE
echo 'set key right bottom' >> $GNU_FILE
echo 'plot "data.txt" using 1:2 with linespoints title "accuracy" lt 4 lw 2 pt 7 ps 1.5 axes x1y2, "data.txt" using 1:3 with linespoints title "loss" lt 3 lw 2 pt 2 ps 1.5 axes x1y1' >> $GNU_FILE
gnuplot $GNU_FILE

rm curve.gnu
rm data.txt