#!/bin/bash

# usage:
# ./getpatternsfromtex.sh INPUT_TeX_FILE
# ./getpatternsfromtex.sh /usr/local/texlive/2023/texmf-dist/tex/generic/hyph-utf8/patterns/tex/hyph-pt.tex > ../data/default.TeX.pt-br.patterns

STARTLINE=$(($(grep -no "\\\\patterns{" $1 | cut -d: -f1)+1))
PATLENGTH=$(($(tail -n +$STARTLINE $1 | grep -n -m1 "}" | cut -d: -f1)-1))
tail -n +$STARTLINE $1 | head -n $PATLENGTH
