#!/bin/bash

word=$1
word4url=$(echo $word | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg' | sed 's/%0A$//g')
curlresult=$(curl -s "https://dicionario.priberam.org/$word4url" | ascii2uni -a U -q)
wordhyph=$(echo $curlresult | grep -P -o '<span\ class="varpt"><span\ style="font\-size:1\.5em;"><b>[^<]+</b>' | grep -P -m 1 -o '<b>[^<]+</b>' |sed -e 's/<b>//' -e 's/<\/b>//'| tr '·' '-' | tr -s '-' | sed -e 's/^\-//g' -e 's/\-$//g')
wordrebuilt=$(echo $wordhyph | sed 's/-//g')
if [[ "$word" == "$wordrebuilt" ]]; then
    echo -e "$wordhyph"
fi
