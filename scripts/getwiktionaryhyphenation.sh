#!/bin/bash

word=$1
word4url=$(echo $word | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg' | sed 's/%0A$//g')
curlresult=$(curl -s "https://pt.wiktionary.org/w/api.php?action=parse&page=$word4url&prop=wikitext&format=json" | ascii2uni -a U -q)
wordhyph=$(echo $curlresult | grep -Po "{(proparoxítona|paroxítona|oxítona)[^}]+}" | head -n1 | tr -d {} | sed -e 's/proparoxítona//g' -e 's/paroxítona//g' -e 's/oxítona//g' -e's/^|//g' -e 's/lang=[a-z]\+//g' -e 's/|$//g' | tr '|' '-')
wordrebuilt=$(echo $wordhyph | sed 's/-//g')
if [[ "$word" == "$wordrebuilt" ]]; then
   echo -e "$wordhyph" 
fi

