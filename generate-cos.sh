# #!/bin/bash

./extractMFE50.sh

./transformMFE50.sh "$1/*.shp"

./sparql-generate.sh -q ../sparql-generate/mfe/cos_original.rqg -i "$1/.shp.json" -v
./sparql-generate.sh -q ../sparql-generate/mfe/cos_simplified.rqg -i "$1/shp_s5_b.json" -v
./sparql-generate.sh -q ../sparql-generate/mfe/cos_merged.rqg -i "$1/*shp_s5_s5_b_d_j_s5_b_c.json" -v

sed -i 's/(((/((/g' $1/*.ttl
sed -i 's/)))/))/g' $1/*.ttl