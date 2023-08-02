#!/bin/bash

temp_file=$(mktemp)
trap 'rm -f "$temp_file"' EXIT ERR INT
cat ../data/hyphagreements | while read line; do word=$(echo "${line%%(*}" | tr -d '-'); echo "$word,$line"; done > "$temp_file"
cat "$temp_file" | 
    awk -F, '
    BEGIN{OFS=FS} 
    {
	for (i=1; i<=NF; i++) gsub("^[[:space:]-]+|[[:space:]-]+$", "", $i);
	if(NF>max_nf) max_nf=NF; rows[NR]=$0
    } 
    END{for(i=1;i<=NR;i++){n=split(rows[i],cols,","); for(j=1;j<max_nf;j++){printf "%s%s", cols[j], OFS} print cols[j]}}
    ' > ../data/hyphagreements.csv


