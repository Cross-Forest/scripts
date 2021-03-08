#!/bin/bash

# This script makes use of csvtk, downloadable at: https://bioinf.shenwei.me/csvtk/
# This script makes use of mdbtools, downloadable at: http://mdbtools.sourceforge.net/

# Change variables to perform operation
declare EXTRACT_TABLES=true
declare MERGE_TABLES=true

if [ ${EXTRACT_TABLES} = true ]
then
    rm -f allTables_ifi.txt
    rm -fr tables_ifi/temp
    mkdir -p tables_ifi/temp
    # Extracting all tables from all files. Each table from each file goes to a different file
    for dbFile in ../data_ifi/*.accdb
    do
        echo Exporting file ${dbFile}
        mdb-tables -1 ${dbFile} > tables_ifi.txt
        cat tables_ifi.txt | tr "[:upper:]" "[:lower:]" >> allTables_ifi.txt
        
        while IFS="" read -r table || [ -n "$table" ]
        do
            table=`echo $table | tr "[:upper:]" "[:lower:]"`
            tableFile="./tables_ifi/temp/${table// /}.csv"
            #echo Exporting table ${table} from file ${dbFile} to ${tableFile}
            #the 1st sed is necessary because there is (at least) one table with wrong name table
            mdb-export ${dbFile} "${table}" | awk -f scientific2decimal_precision8.awk  > "${tableFile}"
        done < tables_ifi.txt
    done
    sort -u -o allTables_ifi.txt allTables_ifi.txt
fi

if [ ${MERGE_TABLES} = true ]
then
    rm tables_ifi/*.csv
    while IFS="" read -r table || [ -n "$table" ]
    do
        filesForTable=(`ls ./tables_ifi/temp/${table// /}.csv | grep -i ${table// /}`)
        if [ ${#filesForTable[@]} -gt 1 ]
        then
            echo "Merging ${#filesForTable[@]} files for table ${table}"
            csvtk concat -k ${filesForTable[@]} > "./tables_ifi/${table// /}.csv"
        else
            echo "Copying 1 file for table ${table}"
            cat ${filesForTable[@]} > "./tables_ifi/${table// /}.csv"
        fi
    done < allTables_ifi.txt
fi
