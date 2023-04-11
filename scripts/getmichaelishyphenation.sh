#!/bin/bash

word=$1
word4url=$(echo $word | perl -p -e 's/([^A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg' | sed 's/%0A$//g')
curlresult=$(curl -s "https://michaelis.uol.com.br/moderno-portugues/busca/portugues-brasileiro/$word4url/" | ascii2uni -a U -q)
wordhyph=$(echo $curlresult | grep -P -m 1 -o '<Es>[^<]+</Es>' | sed -e 's/<Es>//' -e 's/<\/Es>//' | tr '·' '-' | tr -s '-')
wordrebuilt=$(echo $wordhyph | sed 's/-//g')
if [[ "$word" == "$wordrebuilt" ]]; then
  echo -e "$wordhyph" 
fi
