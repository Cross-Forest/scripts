#!/bin/bash

# This script makes use of csvtk, downloadable at: https://bioinf.shenwei.me/csvtk/
# This script assumes you have java installed in your system and the epsgrdf jar in /usr/local/lib/

# Download and preprocess IFN3 files
./extractIFN3.sh

# Join tables to get aggregated data by province
csvtk join -f Origen,Estrato tables/estratos_exs.csv tables/estratos.csv -o tables/provincias_exs.csv

# Run sparql-generate queries
./sparql-generate.sh -q ../sparql-generate/ifn/cambioespecie.rqg -i tables/cambioespecie.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/cambioespeciereg.rqg -i tables/cambioespeciereg.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/estratos.rqg -i tables/estratos.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/estratos_exs.rqg -i tables/estratos_exs.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/mayores_exs.rqg -i tables/mayores_exs.csv -v -s 100000
./sparql-generate.sh -q ../sparql-generate/ifn/parcelas_exs.rqg -i tables/parcelas_exs.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/parcpoly.rqg -i tables/parcpoly.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcdatosmap.rqg -i tables/pcdatosmap.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcespparc.rqg -i tables/pcespparc.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcmatorral.rqg -i tables/pcmatorral.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcmayores.rqg -i tables/pcmayores.csv -s 100000 -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcnueesp.rqg -i tables/pcnueesp.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcparcelas.rqg -i tables/pcparcelas.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/pcregenera.rqg -i tables/pcregenera.csv -v
./sparql-generate.sh -q ../sparql-generate/ifn/provincias_exs.rqg -i tables/provincias_exs.csv -v











# Create positions for WGS84
java -Xmx15000M -jar /usr/local/lib/epsgrdf-1.0-SNAPSHOT-jar-with-dependencies.jar tables/pcdatosmap.ttl tables/pcespparc.ttl tables/pcmayores.ttl ../Ontologies/epsg/Coordinate_Reference_System.ttl