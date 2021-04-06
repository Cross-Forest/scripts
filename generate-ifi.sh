#!/bin/bash

# Process IF files
./extractIFI.sh $1

# Run sparql-generate queries
./sparql-generate.sh -q ../sparql-generate/ifi/desnuts_ES.rqg -i tables_ifi/desnuts.csv -o _ES.ttl -v
./sparql-generate.sh -q ../sparql-generate/ifi/desnuts_PT.rqg -i tables_ifi/desnuts.csv -o _PT.ttl -v
mv tables_ifi/desnuts._ES.ttl tables_ifi/desnuts_ES.ttl
mv tables_ifi/desnuts._PT.ttl tables_ifi/desnuts_PT.ttl

./sparql-generate.sh -q ../sparql-generate/ifi/exsistencias_formdom.rqg -i tables_ifi/exsistencias_formdom.csv -v
./sparql-generate.sh -q ../sparql-generate/ifi/exsistenciasporha_formdom.rqg -i tables_ifi/exsistenciasporha_formdom.csv -v
./sparql-generate.sh -q ../sparql-generate/ifi/estratos_ifn3.rqg -i tables_ifi/estratosifn3.csv -v
