#!/bin/sh

s=5 # simplification level

FILES=$1

DROP_FIELDS="CURRENT_AREA,CURRENT_USE,CURRENT_USE_N4,CURRENT_PCT"
echo $FILES

for f in $@
do  
  real=$(realpath $f)
  json=${real%.json}.json
  box0=${json%.json}_b.json
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
  mapshaper $f -proj +proj=longlat +datum=WGS84 +no_defs -clean -each 'AREA2=this.area/10000,POLYGON=this.id' -o format=geojson precision=0.000001 $json
  echo "*** Adding bounding box to original layer *** $(date) ***"
  mapshaper $json -each 'BBOX=this.bounds' -o $box0
  echo "*** Simplifying original layer *** $(date) ***"
  mapshaper $json -simplify $s% -clean -o $simplified
  echo "*** Adding bounding box to simplified layer *** $(date) ***"
  mapshaper $simplified -each 'BBOX=this.bounds' -o $box
  echo "*** Aggregating polygons by use *** $(date) ***"
  mapshaper $box -dissolve COS2018_n1 -explode -o $dissolved
  echo "*** Adding subpoligons to superpolygons *** $(date) ***"
  mapshaper $dissolved -join $box calc='SUBPOLYGONS=collect(this.properties)' -o $joined
  echo "*** Simplifying merged layer *** $(date) ***"
  mapshaper $joined -simplify $s% -clean -o $simplified2
  echo "*** Adding bounding box to merged layer *** $(date) ***"
  mapshaper $simplified2 -each 'BBOX=this.bounds' -o $box2
  echo "*** Adding superpolygons ID and calculating merged areas*** $(date) ***"
  mapshaper -i $box2 -each \
    'if (SUBPOLYGONS != null) {
      var POLYGON=this.id;
      var AREA=0;
      var CURRENT_AREA=0;
      var CURRENT_PCT=0;
      var MAX_PCT=0;
      var MAX_PCT_N4=0;
      var N1_MAX_PCT="";
      var N4_MAX_PCT="";
      var LG_MAX_PCT="";
      var PCT_N1 = {};
      var PCT_N4 = {};

      for (var polygon in SUBPOLYGONS) {
        AREA+=Math.max(SUBPOLYGONS[polygon].AREA,SUBPOLYGONS[polygon].AREA2);
      }

      for (var polygon in SUBPOLYGONS) {
        CURRENT_AREA = Math.max(SUBPOLYGONS[polygon].AREA,SUBPOLYGONS[polygon].AREA2);
        CURRENT_PCT = CURRENT_AREA / AREA;

        CURRENT_USE = SUBPOLYGONS[polygon].COS2018_n1.substr(0,1);;
        if (PCT_N1[CURRENT_USE] == null) {
          PCT_N1[CURRENT_USE] = 0;
        }
        PCT_N1[CURRENT_USE] += CURRENT_PCT; 

        if (PCT_N1[CURRENT_USE] > MAX_PCT) {
            MAX_PCT = PCT_N1[CURRENT_USE];
            N1_MAX_PCT = CURRENT_USE; 
        }

        CURRENT_USE_N4 = SUBPOLYGONS[polygon].COS2018_n4
        for (var i=0; i < 10; i++) {
          CURRENT_USE_N4 = CURRENT_USE_N4.replace(".","");
        }
        if (PCT_N4[CURRENT_USE_N4] == null) {
          PCT_N4[CURRENT_USE_N4] = 0;
        }
        PCT_N4[CURRENT_USE_N4] += CURRENT_PCT; 

        if (PCT_N4[CURRENT_USE_N4] > MAX_PCT_N4) {
            MAX_PCT_N4 = PCT_N4[CURRENT_USE_N4];
            N4_MAX_PCT = CURRENT_USE_N4; 
            LG_MAX_PCT = SUBPOLYGONS[polygon].COS2018_Lg;
        }
      }
      COS2018_n1=N1_MAX_PCT;
      COS2018_n4=N4_MAX_PCT;
      COS2018_Lg=LG_MAX_PCT;
    }' -drop fields=$DROP_FIELDS -o $calculations
done
