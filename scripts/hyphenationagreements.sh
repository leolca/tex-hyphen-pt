#!/bin/bash

valid_strings=("keep" "replace" "paroxytones" "proparoxytones")

if [ $# -lt 1 ]; then
    echo "Usage: $0 file [-p string]."
    echo "The -p argument must be one of: ${valid_strings[*]}."
    echo "  [keep] apparent proparoxytones (default),"
    echo "  [replace] apparent proparoxytones by both paroxytones and proparoxytones,"
    echo "  [paroxytones] use only the paroxytones case, or" 
    echo "  [proparoxytones] use only the proparoxytones case."
    exit 1
fi

input_source="${1:-/dev/stdin}"

if [ "$input_source" != "/dev/stdin" ]; then
    input_content=$(tail -n +2 "$input_source")
else
    input_content=$(cat)
fi

pstring="keep"
if [ -n "$2" ] && [ "$2" == "-p" ]; then
    if [ -n "$3" ]; then
        provided_string="$3"
	if [[ " ${valid_strings[*]} " == *" $provided_string "* ]]; then
            pstring="$provided_string"
        else
            echo "Error: Invalid string argument. Must be one of: ${valid_strings[*]}"
            exit 1
        fi
    else
        echo "Error: The -p flag requires a string argument. Must be one of: ${valid_strings[*]}" 
        exit 1
    fi
fi

# https://unix.stackexchange.com/questions/609866/regular-awk-easily-sort-array-indexes-to-output-them-in-the-chosen-order
awk -v appprop="$pstring" '
   BEGIN {FS=OFS=","}
   {
   delete hyph_list; delete n_tuple;  
   for(i=2; i<=NF; i++)
       # if($i) hyph_list[$i]+=1; 
       if($i) {
	   # apparent proparoxytone
	   if (appprop != "keep" && $i ~ /:/) {
	       if (appprop == "replace" || appprop == "proparoxytones") {
		   hiatus = gensub(":", "-", "g", $i);
		   hyph_list[hiatus]+=1;
	       }
	       if (appprop == "replace" || appprop == "paroxytones") {
	           diphthong = gensub(":", "", "g", $i);
	           hyph_list[diphthong]+=1;
	       }
	   }
       	   else
	       hyph_list[$i]+=1;
       }
   #for(h in hyph_list) printf "%s(%d)\t",h,hyph_list[h]; if(length(h)>0) print ""

   #for(aa in a) xa[a[aa]]=aa;
   #for(x in xa) printf "%s :: %d ",xa[x],x;
   c = 0;
   for(h in hyph_list) {
       c++;
       n_tuple[c] = "(" hyph_list[h] "," h ")"
   }
   n = length(n_tuple);
   asort(n_tuple)
   #for (i = 1; i <= n; i++) print n_tuple[i];
   for (i = n; i >= 1; i--) {
       gsub(/[\(\)]/, "", n_tuple[i])
       split(n_tuple[i], parts, ",")
       #print parts[2] "," parts[1]
       printf "%s(%d)%s", parts[2], parts[1], (i>1 ? OFS : ORS)
   }

   } 
   ' <<< "$input_content"

   #> ../data/hyphagreements

