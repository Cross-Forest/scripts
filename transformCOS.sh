#!/bin/sh

# mapshaper COS2018_Forest.shp -proj +proj=longlat +datum=WGS84 +no_defs -clean -each 'POLYGON=this.id' -o format=geojson precision=0.000001 COS2018_Forest.json


s=5 # simplification level

FILES=$1

echo $FILES

for f in $@
do  
  real=$(realpath $f)
  json=${real%.json}_s$s.json
  simplified=${json%.json}_s$s.json
  box=${simplified%.json}_b.json
  dissolved=${box%.json}_d.json
  joined=${dissolved%.json}_j.json
  simplified2=${joined%.json}_s$s.json
  box2=${simplified2%.json}_b.json
  calculations=${box2%.json}_c.json

  echo "---------------------------------"
  echo "Processing file: $f"

  echo "*** Exporting to JSON *** $(date) ***"
  mapshaper $f -proj +proj=longlat +datum=WGS84 +no_defs -clean -each 'POLYGON=this.id' -o format=geojson precision=0.000001 $json
  echo "*** Simplifying original layer *** $(date) ***"
  mapshaper $json -simplify $s% -clean -o $simplified
  echo "*** Adding boundig box to original layer *** $(date) ***"
  mapshaper $simplified -each 'BBOX=this.bounds' -o $box
  echo "*** Aggregating polygons by use *** $(date) ***"
  mapshaper $box -dissolve COS2018_n1 -explode -o $dissolved
  echo "*** Adding subpoligons to superpolygons *** $(date) ***"
  mapshaper $dissolved -join $box calc='SUBPOLYGONS=collect(POLYGON),AREA=sum(AREA)' -o $joined
  echo "*** Simplifying merged layer *** $(date) ***"
  mapshaper $joined -simplify $s% -clean -o $simplified2
  echo "*** Adding boundig box to merged layer *** $(date) ***"
  mapshaper $simplified2 -each 'BBOX=this.bounds' -o $box2
  echo "*** Adding superpolygons ID *** $(date) ***"
   mapshaper -i $box2 -each \
    'if (SUBPOLYGONS != null) {
      var POLYGON=""
      for (var pol in SUBPOLYGONS) {

        if (POLYGON == "") {
          POLYGON = SUBPOLYGONS[pol];
        } else {
          POLYGON = POLYGON + "-" + SUBPOLYGONS[pol];
        }
      }
    }' -o $calculations
done