#!/usr/bin/env bash

source=$1
langue=$2

if [ ! "$source" ] || [ ! "$langue" ]
then
    echo "Uso: ./make_pals_corpus_es.sh <dossier_origen> <langue>" >&2
    exit 1
fi

if [ ! -d "$source" ]
then
    echo "Le dossier $source n'existe pas" >&2
    exit 1
fi

find "$source" -name "$langue*.txt" | while read -r file
do
    cat "$file" | while read -r line
    do
        if [[ -z "$line" ]]
        then
            echo ""
        fi

        echo "$line" | egrep -o "\b[[:alnum:]áéíóúüñÁÉÍÓÚÜÑ]+\b" | while read -r token
        do
            echo "$token"
        done
    done
done



