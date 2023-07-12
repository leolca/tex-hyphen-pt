#!/bin/bash

# usage:
# ./getmetrohyphens.sh which-metro output-folder
# example:
# ./getmetrohyphens.sh metro-campinas /tmp/

whichmetro=$1
ofolder=$2

base_url="https://rm.metrolatam.com/pdf/YYYY/MM/DD/YYYYMMDD_${whichmetro}.pdf"
base_filename="${ofolder}/${whichmetro}_YYYYMMDD.txt"

start_date="2011-07-01"  # date of the first edition of Metro 
end_date=$(date +%Y-%m-%d)  # current date

# Convert start and end dates to UNIX timestamps
start_timestamp=$(date -d "$start_date" +%s)
end_timestamp=$(date -d "$end_date" +%s)

# Calculate the number of days between start and end dates
days=$(( (end_timestamp - start_timestamp) / (60*60*24) ))

if [ ! -d "${ofolder}/${whichmetro}" ]; then 
  mkdir "${ofolder}/${whichmetro}"
fi

# Generate the integer number for each date in the range
for ((i = 0; i <= days; i++)); do
  current_date=$(date -u -d "$start_date +$i days" +%Y-%m-%d)
  year=$(date -d "$current_date" -u +%Y)
  month=$(date -d "$current_date" -u +%m)
  day=$(date -d "$current_date" -u +%d)
  # Replace the placeholders in the template URL with the current year, month, and day
  url=${base_url//YYYY/$year}
  url=${url//MM/$month}
  url=${url//DD/$day}
  url=${url//YYYYMMDD/$(date -d "$current_date" -u +%Y%m%d)}
  filename=${base_filename//YYYY/$year}
  filename=${filename//MM/$month}
  filename=${filename//DD/$day}
  echo "$url"
  wget -q "$url" -O "${ofolder}/${whichmetro}.pdf"
  pdftotext -bbox-layout "${ofolder}/${whichmetro}.pdf"
  lynx --dump "${ofolder}/${whichmetro}.html" | grep -Po "[A-Za-záéíóúàâêôãõüç]+\-\s+[A-Za-záéíóúàâêôãõüç]+" | tr -d ' ' > "${ofolder}/${whichmetro}/$filename"
done

