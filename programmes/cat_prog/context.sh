#!/bin/bash

# Récupère pour chaque URL le contexte avant et après le mot cible ("xarxa" ou "xarxes"), correspondant aux deux lignes précédant et suivant le mot cible.
# Entrée : liste d'URL
# Sortie : un fichier texte .txt avec un token par ligne pour chaque URL (un fichier par URL)

# ./programmes/cat_prog/context.sh ../tableaux/URLs.tsv

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
	    echo "Getting context $dump_path" 1>&2
        context_path="./contextes/cat/$lineno.txt"
        cat "$dump_path" | grep -E -i -C 2 "(xarxa|xarxes)" > "$context_path"
    fi

done < $tsv