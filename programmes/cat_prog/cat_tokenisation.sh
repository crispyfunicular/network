#!/bin/bash

# Pour chaque fichier aspiré, ce programme copie chaque mot du fichier sur une ligne d'un nouveau fichier en prenant pour séparateurs les espaces et la ponctuation.
# Entrée : liste d'URL + métadonnées au format tsv
# Sortie : un fichier texte .txt avec un token par ligne pour chaque URL (un fichier par URL)

# ./programmes/cat_prog/cat_tokenisation.sh ../tableaux/URLs.tsv

# $1 first argument passed to the program; "tableaux/URLs.tsv" by default
tsv=${1-tableaux/cat_tableaux/URLs.tsv}


while read -r line;
do

	# increment the line counter by 1	
	lineno=$(echo "$line" | cut -f 1)

    dump_path="./dumps-text/cat_dumps/$lineno.txt"
    if [[ -f "$dump_path" ]]
    then
        # display each line in the stderr
	    echo "Tokenising $dump_path" 1>&2
        tokenisation_path="./tokenisation/cat_tokenisation/$lineno.txt"
        cat "$dump_path" | tr -s "[:punct:][:space:][:cntrl:]" "\n" > "$tokenisation_path"
    fi

done < $tsv