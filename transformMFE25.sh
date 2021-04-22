#!/bin/sh

s=5 # simplification level

FILES=$1

for f in $FILES
do
  real=$(realpath $f)
  json=${real%.shp}.json
  box0=${json%.json}_b0.json
  simplified=${box0%.json}_s$s.json
  box=${simplified%.json}_b1.json
  # dissolved=${box%.json}_d.json
  # joined=${dissolved%.json}_j.json
  # simplified2=${joined%.json}_s$s.json
  # box2=${simplified2%.json}_b.json
  # calculations=${box2%.json}_c.json

  echo "---------------------------------"
  echo "Processing file: $real"

  echo "*** Exporting to JSON ***"
  mapshaper $real -proj +proj=longlat +datum=WGS84 +no_defs -clean -each -o format=geojson precision=0.000001 $json
  echo "*** Removing patches without geometry ***"
  sed -i "/\"coordinates\":\[[^\[]/d" $json
  echo "*** Adding boundig box to original layer ***"
  mapshaper $json -each 'BBOX=this.bounds' -o $box0
  echo "*** Simplifying original layer ***"
  mapshaper $box0 -simplify $s% -clean -o $simplified
  echo "*** Adding boundig box to simplified layer ***"
  mapshaper $simplified -each 'BBOX=this.bounds' -o $box

done