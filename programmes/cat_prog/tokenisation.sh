#!/bin/bash

# Pour chaque fichier aspiré, ce programme copie chaque mot du fichier sur une ligne d'un nouveau fichier
# en prenant pour séparateurs les espaces et la ponctuation.
# lit le fichier `URLs.tsv`, récupère pour chaque ligne le numéro de document (lineno),
# puis remplace toute ponctuation ou caractère non alphanumérique par des espaces,
# en mettant un token par ligne après avoir convertir espaces et caractères de contrôle en retours à la ligne (= tokenisation).
# Le script nettoie au préalable les dossiers de sortie.
# Entrée : liste d'URL + métadonnées au format tsv
# Sortie : un fichier texte .txt avec un token par ligne pour chaque URL (un fichier par URL)

# ./programmes/cat_prog/cat_tokenisation.sh ../tableaux/URLs.tsv

# $1 first argument passed to the program; "tableaux/URLs.tsv" by default
tsv=${1-tableaux/cat_tableaux/URLs.tsv}

mkdir -p ./tokenisation/cat_tokenisation/dumps_tokenisation
rm -rf ./tokenisation/cat_tokenisation/dumps_tokenisation/*

mkdir -p ./tokenisation/cat_tokenisation/contextes_tokenisation
rm -rf ./tokenisation/cat_tokenisation/contextes_tokenisation/*


while read -r line;
do

	# increment the line counter by 1	
	lineno=$(echo "$line" | cut -f 1)

    dump_path="./dumps-text/cat_dumps/$lineno.txt"
    if [[ -f "$dump_path" ]]
    then
        # display each line in the stderr
	    echo "Tokenising $dump_path" 1>&2
        tokenisation_path="./tokenisation/cat_tokenisation/dumps_tokenisation/$lineno.txt"
        # sed : replace all non alphanumerical characters by a space " "
        # tr : replace all space and control characters by \n
        # -s : in cas of multiple characters, replace it by a single one.
        cat "$dump_path" | sed 's/[^[:alnum:]]/ /g' | tr -s '[:space:][:cntrl:]' '\n' > "$tokenisation_path"
    fi

    context_path="./contextes/cat/$lineno.txt"
    if [[ -f "$context_path" ]]
    then
        # display each line in the stderr
	    echo "Tokenising $context_path" 1>&2
        tokenisation_path="./tokenisation/cat_tokenisation/contextes_tokenisation/$lineno.txt"
        # sed : replace all non alphanumerical characters by a space " "
        # tr : replace all space and control characters by \n
        # -s : in cas of multiple characters, replace it by a single one.
        cat "$context_path" | sed 's/[^[:alnum:]]/ /g' | tr -s '[:space:][:cntrl:]' '\n' > "$tokenisation_path"
    fi

done < $tsv