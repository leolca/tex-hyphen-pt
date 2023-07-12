#!/bin/bash

# get portuguese hyphenations from online dictionaries:
# michaelis, priberam, wiktionary, aulete, portal, dicio

# usage example
# ./gethyphenations.sh word
# ./gethyphenations.sh filename
# cat filename | ./gethyphenations.sh
#
# files should have one word per line

if ! command -v gawk &> /dev/null
then
    echo "gawk could not be found"
    echo "please install GNU AWK"
    exit
fi


INPUT=""
if [[ -p /dev/stdin ]]; then # read from stdin
    INPUT="$(cat -)"
elif [ -f "$1" ]; then # read from file
    INPUT="$(cat $1)"
else # read from argument
    tmp="$*"
    INPUT=${tmp// /$'\n'}
    OUTPUTFILE='/dev/stdout'
fi

if [[ -z "${INPUT}" ]]; then
  exit 0
fi

if [[ -z "${OUTPUTFILE}" ]]; then  
    OUTPUTFILE="../data/hyphenations.csv"
    if [ -f "$OUTPUTFILE" ] 
    then
      echo "appending output to $OUTPUTFILE"
    else
      echo "writing output to $OUTPUTFILE"
      echo -e "palavra,michaelis,priberam,wiktionary,aulete,portal,dicio" > "$OUTPUTFILE"
    fi
fi

TMPFM=$(mktemp) || exit 1
TMPFP=$(mktemp) || exit 1
TMPFW=$(mktemp) || exit 1
TMPFA=$(mktemp) || exit 1
TMPFO=$(mktemp) || exit 1
TMPFD=$(mktemp) || exit 1
trap 'rm -f "$TMPFM" "$TMPFP" "$TMPFW" "$TMPFA" "$TMPFO" "$TMPFD"' EXIT

while read word
do
    if [ "$OUTPUTFILE" == "/dev/stdout" ] || ! grep -q "^$word," "$OUTPUTFILE"
    then
	parallel -j 6 ::: hym=$(./getmichaelishyphenation.sh $word > "$TMPFM") hyp=$(./getpriberamhyphenation.sh $word > "$TMPFP") hyw=$(./getwiktionaryhyphenation.sh $word > "$TMPFW") hya=$(./getauletehyphenation.sh $word > "$TMPFA") hyo=$(./getportalhyphenations.sh $word > "$TMPFO") hyd=$(./getdiciohyphenation.sh $word > "$TMPFD")
        hym=$(< "$TMPFM") # read results
        hyp=$(< "$TMPFP")
        hyw=$(< "$TMPFW")
        hya=$(< "$TMPFA")
        hyo=$(< "$TMPFO")
	hyd=$(< "$TMPFD")
        if [ $OUTPUTFILE != "/dev/stdout" ]; then
            echo -e "$word,$hym,$hyp,$hyw,$hya,$hyo,$hyd"
        fi
        echo -e "$word,$hym,$hyp,$hyw,$hya,$hyo,$hyd" >> "$OUTPUTFILE"
        > "$TMPFM" # clear
        > "$TMPFP"
        > "$TMPFW"
        > "$TMPFA"
        > "$TMPFO"
	> "$TMPFD"
    fi
done < <(echo "${INPUT}")

# some dictionary entries might have a leading or tailing - (hyphen)
# we use the following gawk script to remove it
gawk -i inplace -F, 'BEGIN{OFS=FS} {for (i=1;i<=NF;i++) gsub(/^[ -]+|[ -]+$/,"",$i); print $0}' $OUTPUTFILE
