#!/bin/bash

word=$1
word4url=$(echo $word | iconv -f utf8 -t ascii//TRANSLIT)
bword="$word4url"
i=1
while [ $i -le 9 ]
do
    curlresult=$(curl -s "https://www.dicio.com.br/$word4url/" | ascii2uni -a U -q)
    urltitleword=$(echo $curlresult | grep -Po "<title>[^<]+</title>" | sed -e 's/<title>//' -e 's/<\/title>//' | awk '{print tolower($0)}' | cut -d' ' -f1)
    notfound=$(echo $curlresult | grep -A 1 '<div class="title-header">' | grep "<h1>Não encontrada</h1>")
    if [ -z "${notfound// }" ]; then
	if [ "$word" = "$urltitleword" ]; then
	    if echo $curlresult | grep -q "Separação silábica"; then
		break
	    fi
	fi
    else
	exit 1
    fi
    i=$(( $i + 1 ))
    word4url="$bword-$i"
done
wordhyph=$(echo $curlresult | grep -Po "Separação silábica:\s+<b>[^<]+</b>" | grep -P -m 1 -o '<b>[^<]+</b>' | sed -e 's/<b>//' -e 's/<\/b>//' | sed -e 's/^\-//g' -e 's/\-$//g' | awk '{print tolower($0)}')
wordrebuilt=$(echo $wordhyph | sed 's/-//g')
if [[ "$word" == "$wordrebuilt" ]]; then
    echo -e "$wordhyph"
fi
