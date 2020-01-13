#!/bin/bash

# This script makes use of csvtk, downloadable at: https://bioinf.shenwei.me/csvtk/

# Download and preprocess IFN3 files
./extractIFN3.sh

# Join tables to get aggregated data by province
csvtk join -f Origen,Estrato tables/estratos_exs.csv tables/estratos.csv -o tables/provincias_exs.csv

# Run sparql-generate queries
./sparql-generate.sh -q ../sparql-generate/ifn/parcelas_exs.rqg -i tables/parcelas_exs.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcdatosmap.rqg -i tables/pcdatosmap.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcespparc.rqg -i tables/pcespparc.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcmayores.rqg -i tables/pcmayores.csv -s 100000 -v
./sparql-generate.sh -q ../sparql-generate/ifn/provincias_exs.rqg -i tables/provincias_exs.csv -v