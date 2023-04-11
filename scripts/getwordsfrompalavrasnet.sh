#!/bin/bash


letters=( "a" "á" "â" "b" "c" "d" "e" "é" "ê" "f" "g" "h" "i" "í" "j" "k" "l" "m" "n" "o" "ó" "ô" "p" "q" "r" "s" "t" "u" "ú" "v" "w" "x" "y" "z" )
for c in "${letters[@]}"
do
#    curl -s -A "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0" "https://www.palavras.net/search.php?i=$c" | grep "Com esta procura que tem realizado há demasiados resultados" | sed 's/<\/a>/<\/a>\n/g' | grep -o '<a.*a>' | sed -e 's/<a[^>]\+>//g' -e 's/<\/a>//g' | sed 's/<.\+>//g' |  sed '/^$/d'
    curl -s -A "Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/81.0" "https://www.palavras.net/search.php?i=$c" | grep "Palavras com [0-9] letras" | sed 's/<\/a>/<\/a>\n/g' | grep -o '<a.*a>' | sed -e 's/<a[^>]\+>//g' -e 's/<\/a>//g' | sed 's/<.\+>//g' |  sed '/^$/d'
    sleep 3s
done
