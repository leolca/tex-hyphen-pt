#!/bin/bash

# https://unix.stackexchange.com/questions/609866/regular-awk-easily-sort-array-indexes-to-output-them-in-the-chosen-order
tail -n +2 ../data/hyphenations.csv | 
awk '
   BEGIN {FS=OFS=","}
   {
   delete hyph_list; delete n_tuple;  
   for(i=2; i<=NF; i++) if($i) hyph_list[$i]+=1;
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
   ' > ../data/hyphagreements

