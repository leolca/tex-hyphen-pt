#!/bin/bash

compare_strings() {
    # Trim leading and trailing whitespace from the first string
    string1_trimmed="${1#"${1%%[![:space:]]*}"}"
    string1_trimmed="${string1_trimmed%"${string1_trimmed##*[![:space:]]}"}"

    # Trim leading and trailing whitespace from the second string
    string2_trimmed="${2#"${2%%[![:space:]]*}"}"
    string2_trimmed="${string2_trimmed%"${string2_trimmed##*[![:space:]]}"}"

    if [ "$string1_trimmed" == "$string2_trimmed" ]; then
        return 0  # Strings are equal
    else
        return 1  # Strings are different
    fi
}


contains_diacritics() {
    string="$1"

    # Define a regular expression to match diacritic characters
    diacritics_regex='[áéíóúÁÉÍÓÚàèìòùÀÈÌÒÙäëïöüÄËÏÖÜâêîôûÂÊÎÔÛãẽĩõũÃẼĨÕŨ]'

    if echo "$string" | grep -q -P "$diacritics_regex"; then
        return 0  # The string contains diacritic characters
    else
        return 1  # The string does not contain diacritic characters
    fi
}

grep "(5)" ../data/hyphagreements | grep -v "(1)" | grep -v "(2)" | tr -d '()0-9' > ../data/hyphenations5.dic

grep "(5)" ../data/hyphagreements | 
    grep "(1)\|(2)" | 
while read line; do 
  cline=$(echo $line | tr -d '()0-9')
  word1=$(echo $cline | cut -d, -f1); 
  word2=$(echo $cline | cut -d, -f2); 
  count1=$(grep -o '-' <<< "$word1" | wc -l); 
  count2=$(grep -o '-' <<< "$word2" | wc -l); 
  #echo "$word1 $count1 --- $word2 $count2";
  if [ $count1 -gt $count2 ]; then 
    w1=$(echo $word1 | sed 's/\(.*\)-/\1/'); 
    compare_strings "$w1" "$word2"; 
    result=$?;
    if [ $result -ne 0 ]; then
      echo "$word1"
      #echo "c1: $line --->[$w1]x[$word2]";
    else # apparent proparoxytone
      ap=$(echo "$word1" | ./accentposition.awk | cut -d' ' -f2)
      if [ $ap -eq 3 ]; then
	  echo "$word2" # select the paroxytone
      else
	  if ! [[ $word1 =~ [gq]u-[aeio] ]]; then
	      echo "$word1" # select the proparoxytone
          else
	      echo "$word2" # select the paroxytone
	  fi
      fi
    fi; 
  elif [ $count1 -lt $count2 ]; then 
    w2=$(echo $word2 | sed 's/\(.*\)-/\1/'); 
    compare_strings "$w2" "$word1"; 
    result=$?; 
    if [ $result -ne 0 ]; then 
      echo "$word1"
      #echo "c2: $line $word1 $w2";
    else # apparent proparoxytone
      ap=$(echo "$word2" | ./accentposition.awk | cut -d' ' -f2)
      if [ $ap -eq 3 ]; then
	  echo "$word1" # select the paroxytone
      else
	  if ! [[ $word2 =~ [gq]u-[aeio] ]]; then
	      echo "$word2" # select the proparoxytone
	  else
	      echo "$word1" # select the paroxytone
	  fi
      fi
      #echo "ap2: $line"
    fi; 
  else
    echo "$word1"  
    #compare_strings "$word1" "$word2"; 
    #result=$?; 
    #if [ $result -ne 0 ]; then 
    #  echo "xp1: $line"; 
    #else
    #  echo "xp2: $line"
    #fi; 
  fi; 
done >> ../data/hyphenations5.dic



