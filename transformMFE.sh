#!/bin/sh

#$1 should contain the folder where the shp files are

s=5 # simplification level

FILES=$1/*.shp
for f in $FILES
do
  province=${f#$1/mfe50_} ; province=${province%.shp}
  f1=${f%.shp}.json
  f2=${f1%.json}_c.json
  f3=${f2%.json}_s$s.json
  f4=${f3%.json}_u2_s$s.json

  echo "---------------------------------"
  echo "Processing files for province: $province"

  echo "*** Changing to WGS84 ***"
  mapshaper $f -proj +proj=longlat +datum=WGS84 +no_defs -clean -o precision=0.000001 format=geojson $f1
  echo "*** Merging polygons in different municipalities ***"
  mapshaper $f1 -dissolve fields="POLIGON,PROV_MFE50,CCAA_MFE50,TFCCTOT,TFCCARB,FCC_POND,TIPESTR,DISTRIB,FOR_MAN,SP1,O1,E1,SP2,O2,E2,SP3,O3,E3,DEFINICION,CLAS_IFN,USOS_SUELO,CLASMFE_IF,USOS_GENER,TSP1,TSP2,TSP3,TIPO_BOSQU,ID_FORARB,CLA_FORARB,NOM_FORARB,REGBIO" sum-fields="Shape_Leng,Shape_Area" -clean -o format=geojson $f2
  echo "*** Simplifying original layer ***"
  mapshaper $f2 -simplify $s% -clean -o format=geojson $f3
  echo "*** Dissolving by use and simplifying ***"
  mapshaper $f3 -each 'CLAS_IFN2=Math.floor(CLAS_IFN/10)' -dissolve CLAS_IFN2 -simplify $s% -clean -each "PROV_MFE50=$province" -o format=geojson $f4

  # Not necessary after merging polygons in different municipalities
  # echo "*** Removing patches without geometry ***"
  # sed -e "/\"geometry\":null\|\"coordinates\":\[\]/w ${f3%.json}_null.json" -e '//d' $f3 > ${f3%.json}_nn.json
done