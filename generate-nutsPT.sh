#!/bin/bash

mkdir data_nuts_pt
cp $1 data_nuts_pt/
./sparql-generate.sh -q ../sparql-generate/nuts/nutsPT.rqg -i "data_nuts_pt/*.json" -v

sed -i 's/(((/((/g' data_nuts_pt/*.ttl
sed -i 's/)))/))/g' data_nuts_pt/*.ttl
sed -i 's/\(MULTIPOLYGON((\)\([^(].*\)))/\1(\2)))/g' data_nuts_pt/*.ttl
