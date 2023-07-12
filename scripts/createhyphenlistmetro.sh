#!/bin/bash

metros=(
    "metro-abc"
    "metrobh"
    "metro-brasilia"
    "metro-campinas"
    "metro-curitiba"
    "metro-maringa"
    "metro-portoalegre"
    "metro-rio"
    "metro-sao-paulo"
)

# Number of CPU cores
M=$(nproc)

tmpdir=$(mktemp -d)
trap 'cleanup' EXIT

cleanup() {
    read -p "Do you want to remove the temporary folder $tmpdir? [Y/N] " response
    case "$response" in
        [yY])
            rm -rf "$tmpdir"
            ;;
        *)
            echo "Temporary folder $tmpdir will not be removed."
            ;;
    esac
}

printf '%s\n' "${metros[@]}" | parallel -j $M ./getmetrohyphens.sh {} ${tmpdir}

find . -type f -name "${tmpdir}/*.txt" -exec cat {} + >> "${tmpdir}/merged_files"
cat "${tmpdir}/merged_files" | awk '{print tolower($0)}' | sort | tr -s '-' | uniq > "${tmpdir}/metro_hyphens.txt"

cat "${tmpdir}/metro_hyphens.txt" |
    awk '{ 
	hyphen=$0
	gsub(/-/, "", $0)
	word=$0
	if (word in dic) {
	    pos = index(hyphen, "-");
	    value = dic[word]
	    newvalue = ""
	    count=0
	    for (i = 1; i <= length(value); i++) {
		c = substr(value, i, 1)
		newvalue = newvalue c
		if (c != "-") {
		    count++
		    if (count+1 == pos && substr(value, i+1, 1) != "-") {
			newvalue = newvalue "-"
		    }
	        }   
	    }
	    dic[word] = newvalue
	} else { dic[word] = hyphen }
	}

	END {
        # Print the dictionary
        for (key in dic) {
        print key, dic[key]
        }
        }'| sort | cut -d' ' -f2 > "${tmpdir}/metro_jointhyphens.txt"

tmpfile1=$(mktemp)
tmpfile2=$(mktemp)
trap '{ rm -f -- "$tmpfile1" "$tmpfile2"; }' EXIT

FILE="../data/hyphenations.csv"
tail -n +2 "$FILE" | cut -d, -f1 | awk '{ print $0 "," NR }' | sort -t ',' -k 1,1 > "$tmpfile1"
awk 'BEGIN{OFS=","} {hyphen=$0; gsub(/-/, "", $0); print $0,hyphen}' "${tmpdir}/metro_jointhyphens.txt" | sort -t ',' -k 1,1 > "$tmpfile2"
join -t ',' -1 1 -2 1 -a 1 "$tmpfile1" "$tmpfile2" | awk -F, '{print $2 "," $1 "," $3 }' | sort -t ',' -k1,1n | cut -d, -f2,3 > ../data/hyphenations_metro.csv

