#!/bin/bash
#
#
#
#

V="[aeiouáàãâéêíóõôú]" # vowel
C="[^-aeiouáàãâéêíóõôú]" # consonant
CH="[^-aeiouáàãâéêíóõôúh]" # consonant not h

function join_by { local IFS="$1"; shift; echo "$*"; }

patterns=(
    "^${C}+-|-${C}+-|-${C}+$|^${C}$" # cannot have a sequence only consonants and no vowel in hyphenated segments: consonant clusters alone in a syllable are not allowed in Portuguese
    "c-h|l-h|n-h|g-u|q-u" # the digraphs ch, lh, nh, gu, qu should not be split
    "[gq]u-${V}-${C}${V}|[gq]u-${V}-${C}{2}" # bigrams like gu and qu whose vowel u is not pronounced are never separated from the vowel or diphthong that follows it
    "${V}-[nm]${CH}|${V}-[nm]$" # since they are digraphs, a vowel and its following nasalization marker (a graphic nasal consonant) should not be split
    "rr|ss|mm|nn|sc|sç|xc" # the following consonant digraphs should be split: rr, ss, mm, nn, sc, sç and xc 
    # those rules are commented since TeX already avoids leaving a single character orphan
    # removing those hyphens in the source dictionary would lead to hyphenation rules unfitted to other purposes, such as text-to-speech conversion
    #"^([^-]+-){2,}${V}$|^${V}(-[^-]+){2,}$" # words with more than two syllables, when divided, cannot isolate a syllable composed of a single vowel.
    #"^${V}+-[^-]+$|^[^-]+-${V}+$" # disyllables whose syllable has a single vowel should not be split
    "^-|-$" # malformed hyphenation (starting or ending with hyphen)
)

pattern=$(join_by \| "${patterns[@]}")

process_input() {
  while read line
  do
   echo $line | grep -P "${pattern}"
  done
}

input="${1:-/dev/stdin}"

if [[ -f $input || -p $input ]]; then # if a file is given as argument
  process_input < "$input"
else
  if [[ ! -t 0 ]]; then # if stdin has data
    process_input
  else
    process_input <<< "$input"
  fi
fi


