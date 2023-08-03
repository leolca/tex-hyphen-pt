# Number of CPU cores
M=$(nproc)
dics=(
 "michaelis"
 "priberam"
 "wiktionary"
 "aulete"
 "portal"
 "dicio"
)
CSVFILE="../data/hyphenations.csv"
OUTFILE="../data/dic_flgerrors.txt"

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

get_dic_errors() {
    column_name=$1
    dic_file=$2
    destinatio_folder=$3
    column_number=$(head -n 1 "$dic_file" | tr ',' '\n' | grep -n "^$column_name$" | cut -d ':' -f 1)
    tail -n +2 "$dic_file" | cut -d, -f"$column_number" | ./flagwronghyphens.sh > "${destinatio_folder}/${column_name}.err"
}

# Export the function to make it available to parallel
export -f get_dic_errors

printf '%s\n' "${dics[@]}" | parallel -j $M "bash -c 'get_dic_errors {} $CSVFILE $tmpdir'"
for file in $(ls "$tmpdir"); do name=$(basename $file); name=${name%.err}; printf -- '=%.0s' {1..80}; printf "\n%s\n" $name; printf -- '=%.0s' {1..80}; printf "\n"; grep "-" "$tmpdir/$file"; done > "$OUTFILE"

#tail -n +2 ../data/hyphenations.csv | cut -d, -f2 | ./flagwronghyphens.sh > /tmp/michaelis.err
#tail -n +2 ../data/hyphenations.csv | cut -d, -f3 | ./flagwronghyphens.sh > /tmp/priberam.err
#tail -n +2 ../data/hyphenations.csv | cut -d, -f4 | ./flagwronghyphens.sh > /tmp/wikitionary.err
#tail -n +2 ../data/hyphenations.csv | cut -d, -f5 | ./flagwronghyphens.sh > /tmp/aulete.err
#tail -n +2 ../data/hyphenations.csv | cut -d, -f6 | ./flagwronghyphens.sh > /tmp/portal.err
#tail -n +2 ../data/hyphenations.csv | cut -d, -f7 | ./flagwronghyphens.sh > /tmp/dicio.err
#for file in $(ls /tmp/*.err); do name=$(basename $file); name=${name%.err}; printf -- '=%.0s' {1..80}; printf "\n%s\n" $name; printf -- '=%.0s' {1..80}; printf "\n"; grep "-" $file; done > /tmp/erros.txt
