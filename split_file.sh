#!/bin/bash

file=$1
split=$2
extension="${file##*.}"
filename="${file%.*}"
i=1

echo '' > $fout.tmp
if [ $extension  == "json" ]; then
    tail -n +2 "$file" | head -n -1 | split -l $split - "$file"_split_
else
    tail -n +2 "$file" | split -l $split - "$file"_split_
fi
for fsplit in "$file"_split_*; do
    echo "$filename"_"$i"."$extension"
    head -n 1 "$file" > "$filename"_"$i"."$extension"
    cat $fsplit | sed '$s/,$//' >> "$filename"_"$i"."$extension"
    if [ $extension == "json" ]; then
        tail -n -1 "$file" >> "$filename"_"$i"."$extension"
    fi
    ((i++))
done