#!/bin/bash

if [ $# -eq 0 ]
then
    # number of words that have at least one hyphenation found
    tail -n +2 ../data/hyphenations.csv | grep -Pv "[,]{5}$" | wc -l | cut -d' ' -f1
    #cat hyphenations.csv | grep -vP "^[^,][,]{5}" | wc -l | cut -d' ' -f1
else
    if [[ $1 =~ ^-?[0-9]+$ ]]; then
	if [ $1 -lt 0 ]; then
	    wc -l ../data/hyphenations.csv | cut -d' ' -f1
	else
	    # number of words that have N hyphenations found
	    N=$1
            N=$((N+1))
            tail -n +2 ../data/hyphenations.csv | awk -F, '{cnt=0; for(i=1; i<=NF; i++) if($i != "") cnt++;}{print NF,cnt}' | sort | uniq -c | grep -P "[0-9]+ 7 $N" | sed 's/^ *//g' | cut -d' ' -f1
	fi
    fi
fi
