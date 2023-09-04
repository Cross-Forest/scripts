#!/bin/bash
curl -k -G https://crossforest.gsic.uva.es/pruebas/sparql --data-urlencode query=' 
PREFIX ifn: <https://datos.iepnb.es/def/sector-publico/medio-ambiente/ifn/>   
PREFIX spo: <http://crossforest.eu/position/ontology/> 
SELECT ?plot ?lat ?lng 
WHERE {
  ?plot a ifn:Plot ;
     spo:hasPosition ?pos .
  ?pos spo:hasCoordinateReferenceSystem <http://epsg.w3id.org/data/crs/4326> ;
     <http://epsg.w3id.org/ontology/axis/106> ?lat ;
     <http://epsg.w3id.org/ontology/axis/107> ?lng .
}' -H "Accept: text/csv" > plots.csv 
ogr2ogr -f "ESRI Shapefile" -oo X_POSSIBLE_NAMES=lng -oo Y_POSSIBLE_NAMES=lat -a_srs EPSG:4326 plots_IFN3.shp plots.csv 
ogrinfo -sql "CREATE SPATIAL INDEX ON plots_IFN3" plots_IFN3.shp 
ogrinfo -sql "CREATE SPATIAL INDEX ON recintos_muni" recintos_muni.shp 
qgis_process run native:joinattributesbylocation --INPUT=plots_IFN3.shp --JOIN=recintos_muni.shp --PREDICATE=5 --JOIN_FIELDS="" --METHOD=0 --DISCARD_NONMATCHING=0 --PREFIX="" --OUTPUT=Asig_plot_muni.shp 
ogr2ogr -f GeoJSON Asig_plot_muni.json Asig_plot_muni.shp 
/home/natalia/QGIS_automatico/sparql-generate.sh -q /home/natalia/QGIS_automatico/Asig_muni_plot.rqg -i "/home/natalia/QGIS_automatico/Asig_plot_muni.json" -p -Xmx10000M -v

 