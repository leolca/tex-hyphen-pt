#!/bin/bash

# Check a test hyphenation form against a known correct form.  The output mark
# the missing hyphenation points with hyphens (-), the wrong hyphenation points
# with period (.), and the correct hyphenation points with asterisk (*).
#
# usage: 
# ./checkhyphenation.sh correct test 
#
# example:
# ./checkhyphenation.sh tra-ba-lho trab-a-lho
#
# tra-b.a*lho
#    ^ ^ ^
#    | | |
#    | | + -- correct
#    | + ---- wrong
#    + ------ missed

hword=$1
rword=$2
#echo "$hword $rword"
s1=$(echo $hword | sed 's/-//g')
s2=$(echo $rword | sed 's/-//g')
if [[ "$s1" != "$s2" ]]
then
    exit -1
fi
j=0
for (( i=0; i<${#hword}; i++ )); 
do        
   if [[ "${hword:$i:1}" == "${rword:$j:1}" ]]
   then
       if [[ "${hword:$i:1}" == "-" ]] # correct breaking point
       then
	   echo -n "*"
       else
           echo -n "${hword:$i:1}"
       fi
       ((j++))
   elif [[ "${hword:$i:1}" == "-" ]] # missing breaking point
   then
       echo -n "-"
   elif [[ "${rword:$j:1}" == "-" ]] # wrong breaking point
   then
       echo -n "."
       ((j++))
       ((i--))
   fi
done

echo""
