#!/bin/bash

./extractMFE50.sh

./transformMFE50.sh "data/*.shp"

./sparql-generate.sh -q ../sparql-generate/mfe/mfe50.rqg -i "data/*_m_sp_r_s5_b.json" -v
./sparql-generate.sh -q ../sparql-generate/mfe/mfe50_merged.rqg -i "data/*_m_sp_r_s5_b_d_j_s5_b_c.json" -v

sed -i 's/(((/((/g' data/*.ttl
sed -i 's/)))/))/g' data/*.ttl

cd data
find . -name "*_m_sp_r_s5_b.ttl" -exec java -Xmx10000M -jar /usr/local/lib/epsgrdf-1.0-SNAPSHOT-jar-with-dependencies.jar {} \;
find . -name "*_m_sp_r_s5_b_d_j_s5_b_c.ttl" -exec java -Xmx10000M -jar /usr/local/lib/epsgrdf-1.0-SNAPSHOT-jar-with-dependencies.jar {} \;