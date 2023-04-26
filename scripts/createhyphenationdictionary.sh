#!/bin/bash
# Create Hyphenation Dictionary 
# It uses hyphenations from Michaelis, Priberam, Wikitionary, Aulete, Portal and Dicio stored in the source file hyphenations.csv.
#
# usage: 
# ./createhyphenationdictionary.sh N where N is a number from 1 to 6
# (since the source file hyphenations.csv has hyphenations from 6 dictionaries)
#
# example: 
# create a dictionary of hyphenations where 4 dictionaries agree
# ./createhyphenationdictionary.sh 5 > ../data/hyphenations_5.dic 
# create a dictionary from the hyphenations where 6 dictionaries agree
# ./createhyphenationdictionary.sh 6 > ../data/hyphenations_6.dic

N=$1
FILE="../data/hyphenations.csv"

awk -F "," -v N=$N '{
	delete a; 
	for(i=2; i<=NF; i++) 
	    if($i) 
		a[$i]+=1;
	for(aa in a) 
	    if(a[aa] == N) 
		#printf "%s(%d)\n",aa,a[aa]; 
		printf "%s\n",aa;
	}' "$FILE"
