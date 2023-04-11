#!/bin/bash

word=$1
grep "^$word\s" hyphenation-portal.tsv | head -n 1 | cut -f2
