#!/bin/bash

./extractMFE50.sh

./transformMFE50.sh "data/*.shp"

./sparql-generate.sh -q ../sparql-generate/mfe/mfe50_original.rqg -i "data/*_m_sp_r_b.json" -v
./sparql-generate.sh -q ../sparql-generate/mfe/mfe50_simplified.rqg -i "data/*_m_sp_r_s5_b.json" -v
./sparql-generate.sh -q ../sparql-generate/mfe/mfe50_merged.rqg -i "data/*_m_sp_r_s5_b_d_j_s5_b_c.json" -v

sed -i 's/(((/((/g' data/*.ttl
sed -i 's/)))/))/g' data/*.ttl
sed -i 's/\(MULTIPOLYGON((\)\([^(].*\)))/\1(\2)))/g' data/*.ttl