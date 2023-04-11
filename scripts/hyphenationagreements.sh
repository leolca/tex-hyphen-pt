#!/bin/bash

# https://unix.stackexchange.com/questions/609866/regular-awk-easily-sort-array-indexes-to-output-them-in-the-chosen-order
cat ../data/hyphenations.csv | 
awk -F "," '{
   delete a; delete xa; delete idxs;
   for(i=2; i<=NF; i++) if($i) a[$i]+=1;
   #for(aa in sa) printf "%s(%d)\t",aa,a[aa]; if(length(a)>0) print ""

   for(aa in a) xa[a[aa]]=aa;
   #for(x in xa) printf "%s :: %d ",xa[x],x;
   
   n = sort(xa,idxs,"-r")    
   for (i=1; i<=n; i++) {
        idx = idxs[i]
	printf "%s(%d)%s", xa[idx], idx, (i<n ? OFS : ORS)
   }

   } 
 
   function sort(arr, idxs, args,      i, str, cmd) {
      for (i in arr) {
         gsub(/\047/, "\047\\\047\047", i)
         str = str i ORS
      }

      cmd = "printf \047%s\047 \047" str "\047 |sort " args

      i = 0
      while ( (cmd | getline idx) > 0 ) {
         idxs[++i] = idx
      }

      close(cmd)

      return i
   }    
   ' |
   if [ $# -eq 0 ]
   then
       tee /dev/null
   else
       cut -d' ' -f1 | grep "($1)" | wc -l
   fi

