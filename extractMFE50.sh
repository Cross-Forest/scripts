#!/bin/bash

function checkexitstatus {
    if [ "$1" != "0" ]; then
        echo "the command failed with: $1"
        exit $1
    fi
}

# Change variables to perform operation
declare DOWNLOAD_FILES=true
declare UNCOMPRESS_FILES=true
declare EXTRACT_TABLES=true
declare MERGE_TABLES=true

if [ ${DOWNLOAD_FILES} = true ]
then
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_andalucia.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  > links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_aragon.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_asturias.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_baleares.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_canarias.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_cantabria.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_castilla_la_mancha.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_castilla_leon.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_catalugna.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_comunidad_madrid.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_comunidad_valenciana.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_extremadura.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_galicia.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_murcia.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_navarra.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_pais_vasco.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    curl -k https://www.miteco.gob.es/es/biodiversidad/servicios/banco-datos-naturaleza/informacion-disponible/mfe50_descargas_rioja.aspx | grep ".zip" | sed -n "/href/ s/.*href=['\"]\([^'\"]*\)['\"].*/\1/p" |  sed 's|^|https://www.miteco.gob.es|'  >> links.txt
    checkexitstatus $?
    wget --no-check-certificate -i links.txt -P ./data/
    checkexitstatus $?
fi

if [ ${UNCOMPRESS_FILES} = true ]
then
    # Uncompressing files and removing compressed files
    unzip -o -d ./data ./data/"*.zip"
    rm ./data/*.zip
fi