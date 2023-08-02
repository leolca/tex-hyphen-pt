#!/bin/bash

cat ../data/hyphagreements | cut -d',' -f1 | grep "($1)" | wc -l 
