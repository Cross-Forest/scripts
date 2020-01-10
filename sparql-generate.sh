#!/bin/bash

function showhelp {
	echo
	echo "Script to automate sparql-generate executions. Version 0.1, 2020-01-31"
	echo
	echo "Usage $0 [OPTION] querypath"
	echo
    # echo "  -c, --config=<path>             path for configuration file"
    echo "  -e, --inputextension <iext>     extension of input files; adds input file with the same name as the query file, replacing .rqg by .<iext> (.ttl if not set)"
	echo "  -h, --help                      shows this help and exits"
    echo "  -i, --input <path>              path for input file(s); can be a pattern"
    echo "  -j, --jar <path>                path for sparql-generate jar file; overrides -v option"
    echo "  -o, --outputextension <oext>    extension of output files; used in combination with -o"
    echo "  -p, --parameters <parameters>   java parameters (default: -Xmx5000M)"
    echo "  -q, --query <path>              path for query file; can be a pattern (default: query.rqg)"
    echo "  -s, --split <l>                 split input file(s) in files of l lines"
    echo "  -v, --verbose                   verbose output"
    echo "  -V, --version [1|2]             sparql-generate version to use. 1 for 1.1 and 2 for 2.0 (default: 1)"
	echo
}

function buildcommand {
    jarcommand="java $javaparameters"
    if [[ $givenjar -ne "" ]]; then
        jarcommand="$jarcommand -jar $givenjar"
    else
        jarcommand="$jarcommand -jar $jarpath"
    fi
    jarcommand="$jarcommand $@"
    echo $jarcommand
}

#defaults
declare sparqlgenerate1="/usr/local/lib/sparql-generate-1.1.jar"
declare sparqlgenerate2="/usr/local/lib/sparql-generate-2.0-SNAPSHOT.jar"
declare jarpath=$sparqlgenerate1
declare givenjar=""
declare javaparameters="-Xmx5000M"
declare source="urn:source"
declare fquery="query.rqg"
declare finput
declare fcongif
declare redirection="/dev/null"
declare inputextension
declare outputextension="ttl"
declare -i split

if [ $# -eq 0 ]; then
    showhelp
    exit 0
fi

getopt --test > /dev/null
if [[ $? -eq 4 ]]; then
    # enhanced getopt works
    OPTIONS=c:e:hi:j:o:p:q:s:vV:
	LONGOPTIONS=config:,inputextension:,help,input:,jar:,outputextension:,parameters:,query:,split:,verbose,version:
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
        # -c|--config)
        #     fcongif=$2
        #     shift 2
        #     ;;
        -e|--inputextension)
            inputextension=$2
            shift 2
            ;;
        -i|--input)
            if [[ $2 == \~/* ]]; then
                finput=$HOME/${2#"~/"}
            else
                finput=$2
            fi
            shift 2
            ;;
        -j|--jar)
            if [[ $2 == \~/* ]]; then
                givenjar=$HOME/${2#"~/"}
            else
                givenjar=$2
            fi
            shift 2
            ;;
        -o|--outputextension)
            outputextension=$2
            shift 2
            ;;
        -p|--parameters)
            javaparameters=$2
            shift 2
            ;;
        -q|--query)
            if [[ $2 == \~/* ]]; then
                fquery=$HOME/${2#"~/"}
            else
                fquery=$2
            fi
            shift 2
            ;;
        -s|--split)
            split=$2
            shift 2
            ;;
		-v|--verbose)
			redirection="/dev/stderr"
			shift
			;;
        -V|--version)
            case "$2" in
                "1") jarpath=$sparqlgenerate1 ;;
                "2") jarpath=$sparqlgenerate2 ;;
                *) echo "non-valid option for version. Defaulting to $jarpath." ;;
            esac
            shift 2
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "here"
            showhelp
            exit 0
            ;;
    esac
done

for fq in $fquery; do
    if [ ! -z "$inputextension" ]; then
        fin=$(realpath ${fq%.rqg}.$inputextension)
        fout=$(realpath ${fq%.rqg}.$outputextension)
        jarcommand=$(buildcommand -q $fq -o $fout --source \"$source\"=\"file://$fin\")
        echo $jarcommand > $redirection
        eval $jarcommand > $redirection
    elif [ ! -z "$finput" ]; then
        for fi in $finput; do
            fin=$(realpath $fi)
            fout=${fin%.$finputextension}.$outputextension # check if this expansion works
            jarcommand=$(buildcommand -q $fq -o $fout --source \"$source\"=\"file://$fin\")
            echo $jarcommand > $redirection
            eval $jarcommand > $redirection
        done
    else
        foutput=$(realpath ${fq%.rqg}.$outputextension)
        jarcommand=$(buildcommand -q $fq -o $foutput)
        echo $jarcommand > $redirection    
        eval $jarcommand 2> $redirection  
    fi
done