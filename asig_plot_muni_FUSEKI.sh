#!/bin/bash
curl -X POST --data "query= \
PREFIX spatialF: <http://jena.apache.org/function/spatial#> \
PREFIX wkt: <http://www.opengis.net/ont/geosparql#> \
PREFIX spo: <http://crossforest.eu/position/ontology/> \
PREFIX geof: <http://www.opengis.net/def/function/geosparql/> \
PREFIX ifn: <https://datos.iepnb.es/def/sector-publico/medio-ambiente/ifn/> \
PREFIX crs: <http://epsg.w3id.org/data/crs/> \
PREFIX axis: <http://epsg.w3id.org/ontology/axis/> \
CONSTRUCT {?plot  ifn:isInMunicipality ?muni} \
WHERE { \
   ?plot a ifn:Plot; spo:hasPosition ?spo. \
   ?spo spo:hasCoordinateReferenceSystem crs:4326; \
     axis:106 ?lat;  \
     axis:107 ?lng .  \
   ?muni spo:hasPolygon ?poly .  \
   ?poly wkt:asWKT ?wkt_muni.    \
   BIND(spatialF:convertLatLon(?lat, ?lng) as ?point)  \
   FILTER(geof:sfWithin(?point, ?wkt_muni)). \
}" \
-H 'Accept:application/x-turtle' http://localhost:3034/Municipios/query > Asig_plot_N.ttl 