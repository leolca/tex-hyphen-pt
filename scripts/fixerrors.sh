#!/bin/bash

# 1) removes empty space and underscore from each field.
#
# 2) check if the field has a hyphenated word (we consider that a string with
# more that 4 characters, no dash and at least two vowels non contiguous is a
# word that was not hyphenated)
#
# 3) check if the field value, after removing the dashes, has the righteous word
#
# 4) print the fields after those tests
#
# usage:
# ./fixerrors.sh ../data/hyphenations.csv > /tmp/hyphenations.csv
# diff --suppress-common-lines ../data/hyphenations.csv /tmp/hyphenations.csv | more
# cp /tmp/hyphenations.csv ../data/hyphenations.csv

FILE=$1
awk -F, '
	BEGIN{OFS=FS}
	NR == 1 { print; }
	NR > 1 {
	    printf "%s%s", $1, OFS; 
	    for (i=2;i<=NF;i++) {
		gsub(/[_ ]/, "", $i);
		if (length($i)>4 && $i !~ /-/ && $i ~ /[aeiou][^aeiou]+[aeiou]/)
		    $i="";
		str=$i; 
		gsub("-","",str); 
		if(str==$1) printf "%s", $i;
    	        if (i < NF) printf "%s", OFS;
		else printf "%s", RS;
		} 
	}' $FILE
