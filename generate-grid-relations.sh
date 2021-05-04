#!/bin/bash

# Run sparql-generate queries

for f in `ls $1`
do
  ./sparql-generate.sh -q ../sparql-generate/grid/grid-relations.rqg -i $1/$f -v
done
