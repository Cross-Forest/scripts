#!/bin/bash

# This script makes use of csvtk, downloadable at: https://bioinf.shenwei.me/csvtk/

# Change variables to perform operation
declare DOWNLOAD_FILES=true
declare UNCOMPRESS_FILES=true
declare EXTRACT_TABLES=true
declare MERGE_TABLES=true

if [ ${DOWNLOAD_FILES} = true ]
then
    # Downloading files from webpage
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/ifn3_base_datos_1_25.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  > links.txt
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/ifn3_base_datos_26_50.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    wget --no-check-certificate -i links.txt -P ./data/
fi

if [ ${UNCOMPRESS_FILES} = true ]
then
    # Uncompressing files and removing compressed files
    unzip -o -d ./data ./data/"*.zip"
    rm ./data/*.zip
fi

if [ ${EXTRACT_TABLES} = true ]
then
    rm -f allTables.txt
    rm -fr tables/temp
    mkdir -p tables/temp
    # Extracting all tables from all files. Each table from each file goes to a different file
    for dbFile in ./data/*.mdb
    do
        echo Exporting file ${dbFile}
        province=${dbFile%.*}
        province=${province: -2:2}
        mdb-tables -1 ${dbFile} > tables.txt
        cat tables.txt | tr "[:upper:]" "[:lower:]" >> allTables.txt
        
        while IFS="" read -r table || [ -n "$table" ]
        do
            table=`echo $table | tr "[:upper:]" "[:lower:]"`
            tableFile="./tables/temp/${table// /}-${province}.csv"
            #echo Exporting table ${table} from file ${dbFile} to ${tableFile}
            #the 1st sed is necessary because there is (at least) one table with wrong name table
            mdb-export ${dbFile} "${table}" | awk -f scientific2decimal.awk | sed "1,1s|Distancia|Distanci|" | sed "1,1s|^|Origen,|" | sed  "2,\$s|^|${province},|" > "${tableFile}"
        done < tables.txt
    done
    sort -u -o allTables.txt allTables.txt
fi

if [ ${MERGE_TABLES} = true ]
then
    rm tables/*.csv
    while IFS="" read -r table || [ -n "$table" ]
    do
        filesForTable=(`ls ./tables/temp/${table// /}-*.csv | grep -i ${table// /}`)
        if [ ${#filesForTable[@]} -gt 1 ]
        then
            echo "Merging ${#filesForTable[@]} files for table ${table}"
            csvtk concat -k ${filesForTable[@]} > "./tables/${table// /}.csv"
        else
            echo "Copying 1 file for table ${table}"
            cat ${filesForTable[@]} > "./tables/${table// /}.csv"
        fi
    done < allTables.txt
fi