#!/bin/bash
function showHelp()
{
   # Display Help
   echo "Script to delete wrong municipalities from plots in IFN3"
   echo
   echo "Usage $0 [OPTIONS]"
   echo
   echo "Syntax:  [-e|-h|-m|-o|-p|-s]"
   echo "options:"
   echo "-e, --endpoint 	SPARQL Endpoint (only if --static=false)."
   echo "-h, --help 		Print this Help."
   echo "-m, --municipalities	Full path for wrong municipalities list (only if --static=true, wrongMunicip.csv [default])."
   echo "-o, --output 		Output ttl file (pcparcelas-municipalitiesIFN3.ttl [default])."
   echo "-p, --plots 		Full path for plots file (tables/pcparcelas.ttl [default])."
   echo "-s, --static  		Read wrong municipalities from file or query SPARQL (boolean: true[default]/false)."
   echo
}

#defaults
declare sparql="https://crossforest.gsic.uva.es/pruebas/sparql"
declare static=true
declare munError="wrongMunicip.csv"
declare plot="tables/pcparcelas.ttl"
declare out="pcparcelas-municipalitiesIFN3.ttl"

if [ $# -eq 0 ]; then
    showHelp
#    exit 0
fi

getopt --test > /dev/null
if [[ $? -eq 4 ]]; then
    # enhanced getopt works
    OPTIONS=e:hm:o:p:s:
    LONGOPTIONS=endpoint:help,municipalities:,plots:,output:,static:
    COMMAND=$(getopt -o $OPTIONS -l $LONGOPTIONS -n "$0" -- "$@")
    if [[ $? -ne 0 ]]; then
    	exit 2
    fi
    eval set -- "$COMMAND"
else
	echo "Enhanced getopt not supported. Brace yourself, this is not tested, but it should work as long as each argument is separated."
fi

while true; do
    case "$1" in
         -h|--help)
            showHelp
	    exit 0     
            ;;
	-s|--static)
            static=$2
            shift 2
            ;;
	-p|--plots)
            plot=$2
            shift 2
            ;;
	-m|--municipalities)
            munError=$2
            shift 2
            ;;
	-o|--output)
            out=$2
            shift 2
            ;;
	-e|--endpoint)
            sparql=$2
            shift 2
            ;;
   	 --)
            shift
            break
            ;;
        *)
            echo "here"
            showHelp
            exit 0
            ;;
    esac
done
if  [ -f "$plot" ]; then
	if  ! $static 
	then
		curl -X POST -H "Content-Type: application/sparql-query" -H 'Accept: text/csv' --data "select distinct ?m where {
		?p a <https://datos.iepnb.es/def/sector-publico/medio-ambiente/ifn/Plot> ;
		<https://datos.iepnb.es/def/sector-publico/medio-ambiente/ifn/isInMunicipality> ?m .
		FILTER NOT EXISTS { ?m [] [] } }" "$sparql" |sed '1d'| tr -d '\"' > $munError
		if [[ ! -s $munError ]]; then
			echo "Zero wrong  municipalities in SPARQL. Exit"
			exit 0
		fi
	fi
	echo "Parsing and deleting wrong munipalities from plots"
	grep -v -F -f $munError $plot | sed -z 's/;\n\n/\.\n\n/g' > $out
	echo "Plots in file: $out"
else
	echo "Plots' file not exists."
fi
