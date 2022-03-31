#!/bin/bash

# Change variables to perform operation
declare DOWNLOAD_FILES=true
declare data="https://www.ine.es/daco/daco42/codmun/diccionario22.xlsx"

declare file="./tables/${data##*/}"
declare out="${file%.*}.csv"
declare out_tmp=$out".tmp"
if [ ${DOWNLOAD_FILES} = true ]
then
    # Downloading files from webpage
    wget --no-check-certificate $data -P ./tables/ > /dev/null
    csvtk xlsx2csv -D ";" $file > $out_tmp
    sed -i '1d' $out_tmp
    awk  -F";" -vOFS=";" 'NR==1{print $0} FNR>1 { printf "%s;%02d;%03d;%s;%s\n", $1, $2, $3, $4, $5}' $out_tmp > $out
    
    rm $file $out_tmp
else
	echo "Existing files"
fi

./sparql-generate.sh -q ../sparql-generate/ifn/municipalities_ine.rqg -i "$out" -v
