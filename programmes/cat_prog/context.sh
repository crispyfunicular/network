#!/bin/bash

# Récupère pour chaque URL le contexte avant et après le mot cible ("xarxa" ou "xarxes"),
# correspondant aux deux lignes précédant et suivant le mot cible.
# lit le fichier `URLs.tsv`, récupère pour chaque ligne le numéro de document (lineno),
# puis parcourt le dump texte associé pour extraire tous les passages contenant le mot-cible xarxa|xarxes.
# Pour chaque occurrence, le script conserve 2 lignes avant et 2 lignes.
# Entrée : liste d'URL
# Sortie : Un fichier texte par URL avec une succession de contextes (séparés par ---) constitués des deux lignes précédant et suivant le mot-cible.

# ./programmes/cat_prog/context.sh ../tableaux/URLs.tsv

# $1 first argument passed to the program; "tableaux/URLs.tsv" by default
tsv=${1-tableaux/cat_tableaux/URLs.tsv}

mkdir -p ./contextes/cat
rm -rf ./contextes/cat/*

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