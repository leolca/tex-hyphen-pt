#!/bin/bash

if [ $# -eq 0 ]
then
    tail -n +2 ../data/hyphenations.csv | grep -Pv "[,]{5}$" | wc -l | cut -d' ' -f1
    #cat hyphenations.csv | grep -vP "^[^,][,]{5}" | wc -l | cut -d' ' -f1
else
    N=$1
    N=$((N+1))
    tail -n +2 ../data/hyphenations.csv | awk -F, '{cnt=0; for(i=1; i<=NF; i++) if($i != "") cnt++;}{print NF,cnt}' | sort | uniq -c | grep -P "[0-9]+ 7 $N" | sed 's/^ *//g' | cut -d' ' -f1
fi
