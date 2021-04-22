#!/bin/bash

./transformMFE25.sh "data/*.shp"
./extractMFE25.sh

./sparql-generate.sh -q ../sparql-generate/mfe/mfe25_original.rqg -i "data/*_b0.json" -p -Xmx10000M -v
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25_simplified.rqg -i "data/*_b0_s5_b1.json" -p -Xmx10000M -v
# ./sparql-generate.sh -q ../sparql-generate/mfe/mfe25_merged.rqg -i "data/*_b0_s5_b1_....json" -v

sed -i 's/(((/((/g' data/*.ttl
sed -i 's/)))/))/g' data/*.ttl

./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_50_25.rqg -i tables_mfe/mfe_50_25.csv -s 100000 -v
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_claifn.rqg -i tables_mfe/mfe_claifn.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_clamfe.rqg -i tables_mfe/mfe_clamfe.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_desatrib.rqg -i tables_mfe/mfe_desatrib.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_descsupraforarb.rqg -i tables_mfe/mfe_descsupraforarb.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_desesparb.rqg -i tables_mfe/mfe_desesparb.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_desestado.rqg -i tables_mfe/mfe_desestado.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_desforarb.rqg -i tables_mfe/mfe_desforarb.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_desforher.rqg -i tables_mfe/mfe_desforher.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_desformat.rqg -i tables_mfe/mfe_desformat.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_desmodcomb.rqg -i tables_mfe/mfe_desmodcomb.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_dessubfor.rqg -i tables_mfe/mfe_dessubfor.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_destipestr.rqg -i tables_mfe/mfe_destipestr.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_distrib.rqg -i tables_mfe/mfe_distrib.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_etes.rqg -i tables_mfe/mfe_etes.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_tc_regbio.rqg -i tables_mfe/mfe_pasarela_maxa_lulucf.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_tipoestrmfe50.rqg -i tables_mfe/mfe_tc_regbio.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_t_clase.rqg -i tables_mfe/mfe_tipoestrmfe50.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_t_clase50.rqg -i tables_mfe/mfe_t_clase.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/tbcod_prov_ccaa.rqg -i tables_mfe/mfe_t_clase50.csv
./sparql-generate.sh -q ../sparql-generate/mfe/mfe25/mfe_pasarela_maxa_lulucf.rq -i tables_mfe/tbcod_prov_ccaa.csv