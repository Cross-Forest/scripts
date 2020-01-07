#!/bin/bash

jarpath="/home/chemi/Documents/Workspaces/Java/json2rdf/target/json2rdf-1.0-SNAPSHOT-jar-with-dependencies.jar"

for file in $1
do
    [ -f "$file" ] || break
    pathfile=$(realpath $file)
    echo "Processing file $pathfile"
    java -jar $jarpath $pathfile $2 > ${pathfile%.json}.ttl
done