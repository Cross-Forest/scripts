#!/bin/bash

mkdir data_nuts_es
cp $1 data_nuts_es/
./sparql-generate.sh -q ../sparql-generate/nuts/nutsES.rqg -i "data_nuts_es/*.json" -v

sed -i 's/(((/((/g' data_nuts_es/*.ttl
sed -i 's/)))/))/g' data_nuts_es/*.ttl
sed -i 's/\(MULTIPOLYGON((\)\([^(].*\)))/\1(\2)))/g' data_nuts_es/*.ttl
