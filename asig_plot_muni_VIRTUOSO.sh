#!/bin/bash
curl -X POST http://localhost:8890/sparql --data-urlencode  "query= \
PREFIX ifn: <https://datos.iepnb.es/def/sector-publico/medio-ambiente/ifn/> \
PREFIX spo: <http://crossforest.eu/position/ontology/> \
PREFIX crs: <http://epsg.w3id.org/data/crs/> \
PREFIX axis: <http://epsg.w3id.org/ontology/axis/> \
PREFIX wkt: <http://www.opengis.net/ont/geosparql#> \
CONSTRUCT {?plot ifn:isInMunicipality ?muni} \
WHERE { \
     ?plot a ifn:Plot; \
        spo:hasPosition ?pos. \
     ?pos spo:hasCoordinateReferenceSystem crs:4326 ; \
        axis:106 ?lat ; \
        axis:107 ?lng . \
     ?muni spo:hasPolygon ?poly . \
     ?poly wkt:asWKT ?wkt_muni . \
     FILTER (bif:st_within(bif:st_point(xsd:double(?lng), xsd:double(?lat)), ?wkt_muni)) \
}" \
--data-urlencode "default-graph-uri=http://crossforest.eu"  -H 'Accept:application/x-turtle'  > muni_plot_Virtuoso.ttl 