#!/bin/sh

s=5 # simplification level

FILES=$1
for f in $FILES
do
  province=${f#*mfe50_} ; province=${province%.shp}
  real=$(realpath $f)
  json=${real%.shp}.json
  municipalities=${json%.json}_m.json
  species=${municipalities%.json}_sp.json
  clean=${species%.json}_r.json
  simplified=${clean%.json}_s$s.json
  box=${simplified%.json}_b.json
  dissolved=${box%.json}_d.json
  joined=${dissolved%.json}_j.json
  simplified2=${joined%.json}_s$s.json
  box2=${simplified2%.json}_b.json
  calculations=${box2%.json}_c.json

  # echo "f=$f"
  # echo "real=$real"
  # echo "json=$json"
  # echo "municipalities=$municipalities"
  # echo "species=$species"
  # echo "clean=$clean"
  # echo "simplified=$simplified"
  # echo "box=$box"
  # echo "dissolved=$dissolved"
  # echo "joined=$joined"
  # echo "simplified2=$simplified2"
  # echo "box2=$box2"

  echo "---------------------------------"
  echo "Processing files for province: $province"

  echo "*** Exporting to JSON ***"
  mapshaper $f -proj +proj=longlat +datum=WGS84 +no_defs -clean -each "PROV_MFE50=$province" -o format=geojson precision=0.000001 $json
  echo "*** Merging polygons of different municipalities ***"
  mapshaper $json -dissolve fields="POLIGON,PROV_MFE50,CCAA_MFE50,TFCCTOT,TFCCARB,FCC_POND,TIPESTR,DISTRIB,FOR_MAN,SP1,O1,E1,SP2,O2,E2,SP3,O3,E3,DEFINICION,CLAS_IFN,USOS_SUELO,CLASMFE_IF,USOS_GENER,TSP1,TSP2,TSP3,TIPO_BOSQU,ID_FORARB,CLA_FORARB,NOM_FORARB,REGBIO" sum-fields="Shape_Leng,Shape_Area"  -clean -o $municipalities
  echo "*** Merging species in array ***"
  mapshaper $municipalities -each 'if(SP3>0){SPECIES=[[SP1,O1*10,E1],[SP2,O2*10,E2],[SP3,O3*10,E3]]} else if(SP2>0){SPECIES=[[SP1,O1*10,E1],[SP2,O2*10,E2]]} else if(SP1>0){SPECIES=[[SP1,O1*10,E1]]}' -drop fields="SP1,SP2,SP3,O1,O2,O3,E1,E2,E3,TSP1,TSP2,TSP3" -o $species
  echo "*** Removing empty fields ***"
  mapshaper $species -each 'if (this.properties != null) {for (var property in this.properties) { if(this.properties[property] === "" || this.properties[property] === null){delete this.properties[property]}}}'  -o $clean
  echo "*** Simplifying original layer ***"
  mapshaper $clean -simplify $s% -clean -o $simplified
  echo "*** Adding boundig box to original layer ***"
  mapshaper $simplified -each 'BBOX=this.bounds' -o $box
  echo "*** Aggregating polygons by use ***"
  mapshaper $box -each 'CLAS_IFN2=Math.floor(CLAS_IFN/10)' -dissolve CLAS_IFN2 -explode -each "PROV_MFE50=$province" -o $dissolved
  echo "*** Adding subpoligons to superpolygons ***"
  mapshaper $dissolved -join $box calc='SUBPOLYGONS=collect(this.properties), Shape_Area=sum(Shape_Area), Shape_Leng=sum(Shape_Leng)' fields="POLIGON" -o $joined
  echo "*** Simplifying merged layer ***"
  mapshaper $joined -simplify $s% -clean -o $simplified2
  echo "*** Adding boundig box to merged layer ***"
  mapshaper $simplified2 -each 'BBOX=this.bounds' -o $box2

  mapshaper -i $box2 -each \
    'if (SUBPOLYGONS != null) {
      var USES = {};
      var SPECIES = {}
      var TFCCTOT=0;
      var TFCCARB=0;
      for (var polygon in SUBPOLYGONS) {
        var proportion=(SUBPOLYGONS[polygon].Shape_Area/Shape_Area);
        
        if (USES[SUBPOLYGONS[polygon].CLAS_IFN] == undefined) {
          USES[SUBPOLYGONS[polygon].CLAS_IFN] = 0;
        }
        USES[SUBPOLYGONS[polygon].CLAS_IFN]+=proportion*100;

        for (var species in SUBPOLYGONS[polygon].SPECIES) {
          if (SPECIES[SUBPOLYGONS[polygon].SPECIES[species][0]] == undefined) SPECIES[SUBPOLYGONS[polygon].SPECIES[species][0]] = 0;
          SPECIES[SUBPOLYGONS[polygon].SPECIES[species][0]]+=SUBPOLYGONS[polygon].SPECIES[species][1]*proportion;
        }
        for (var species in SPECIES) {
          SPECIES[species]=Math.round(SPECIES[species]);
        }

        TFCCTOT+=SUBPOLYGONS[polygon].TFCCTOT*proportion;
        TFCCARB+=SUBPOLYGONS[polygon].TFCCARB*proportion;
      }
      var max = null;
		  var CLAS_IFN = null;
      for (var use in USES) {
        if (max == null || USES[use] > max) {
          CLAS_IFN = use;
          max = USES[use];
        }
        USES[use]=Math.round(USES[use]);
      }
      TFCCTOT=Math.round(TFCCTOT);
      TFCCARB=Math.round(TFCCARB);
    }' -drop fields="max,proportion" -o $calculations
done