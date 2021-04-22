#!/bin/bash

# This script makes use of csvtk, downloadable at: https://bioinf.shenwei.me/csvtk/
# This script makes use of mdbtools, downloadable at: http://mdbtools.sourceforge.net/
# This script makes use of unzip, downloadable at: http://infozip.sourceforge.net/

rm -f allTables_mfe.txt
rm -fr tables_mfe
mkdir -p tables_mfe
# Extracting all tables from all files. Each table from each file goes to a different file
for dbFile in data/*.mdb
do
    echo Exporting file ${dbFile}
    mdb-tables -1 ${dbFile} > tables_mfe.txt
    
    while IFS="" read -r table || [ -n "$table" ]
    do
        table=`echo $table | tr "[:upper:]" "[:lower:]"`
        tableFile="./tables_mfe/${table// /}.csv"
        echo Exporting table ${table} from file ${dbFile} to ${tableFile}
        #the 1st sed is necessary because there is (at least) one table with wrong name table
        mdb-export ${dbFile} "${table}" | awk -f scientific2decimal.awk > "${tableFile}"
    done < tables_mfe.txt
done