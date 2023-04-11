#!/bin/bash

# Compare a two (or more) hyphenations. The first form given is assumed the correct one.
# As a result, the count of correct and wrong hyphenation-parts for each form presented.
#
# usage:
# ./comparehyphenations.sh correct test1 test2 ...
#
# example:
# ./comparehyphenations.sh gi-ná-sio gi-ná-sio
#       3       0
#   (correct)(wrong)
#
# ./comparehyphenations.sh gi-ná-sio gi-ná-si-o
# 	2	1
#   (correct)(wrong)
#
# ./comparehyphenations.sh gi-ná-si-o gi-ná-sio
#	2	2
#   (correct)(wrong)
#
# ./comparehyphenations.sh gi-ná-sio gi-ná-si-o giná-sio
#	2	1
#	1	2
#   (correct)(wrong)

args=("$@")
right=${args[0]}
argslen=${#args[@]}
rword=$(echo $right | tr -d '-')

fail=0
# check if all given hyphenated forms are for the same sequence (word)
for (( j=1; j<argslen; j++ ));
do
    word=$(echo ${args[$j]} | tr -d '-')
    [[ "$rword" != "$word" ]] && fail=1
done

if [[ "$fail" == 1 ]]; then
    echo "failed! words are different"
    exit 1
fi

IFS='-' read -ra rightH <<< "$right"
rhlen=${#rightH[@]}

# use C style for loop syntax to read all values and indexes
for (( j=1; j<argslen; j++ ));
do
  rcount=0
  wcount=0
  word=${args[$j]}
  IFS='-' read -ra wordH <<< "$word"
  wlen=${#wordH[@]}
  k=0
  for (( i=0; i<rhlen; i++ ));
  do
    if (( k > wlen )); then
	((wcount++))
    else
	if [[ "${rightH[i]}" == "${wordH[k]}" ]]; then
	    ((rcount++))
	    ((k++))
	else
	    ((wcount++))
	    STR=$(echo "${rightH[@]:0:i+1}" | tr -d ' ')
	    SUB=$(echo "${wordH[@]:0:k+1}" | tr -d ' ')
	    if [[ "$STR" == *"$SUB"* ]]; then
		((k++))
	    fi
	fi
    fi  
    #if (( i > wlen )); then
    #    ((wcount++))
    #else
    #    if [[ "${rightH[i]}" == "${wordH[i]}" ]]; then
    #        ((rcount++))
    #    else
    #        ((wcount++))
    #    fi
    #fi
  done
  echo -e "\t$rcount\t$wcount"
done

