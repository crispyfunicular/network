#!/bin/bash

# Pour chaque fichier aspiré puis tokenisé, ce programme associe un mot et le mot suivant (sur la ligne suivante) de façon à obtenir des bigrammes.
# Entrée : liste d'URL + métadonnées au format tsv
# Sortie : un fichier texte .txt avec deux tokens contigus par ligne pour chaque URL (un fichier par URL). L'intégralité des tokens sont traités pour une URL.

# ./programmes/cat_prog/cat_tokenisation.sh ../tableaux/URLs.tsv

# $1 first argument passed to the program; "tableaux/URLs.tsv" by default
tsv=${1-tableaux/cat_tableaux/URLs.tsv}


while read -r line;
do

	# increment the line counter by 1	
	lineno=$(echo "$line" | cut -f 1)

    tokenisation_path="./tokenisation/cat_tokenisation/$lineno.txt"
    if [[ -f "$tokenisation_path" ]]
    then
        # display each line in the stderr
	    echo "Getting bigrams $tokenisation_path" 1>&2
        bigrammes_path="./bigrammes/cat/$lineno.txt"
        # 1. tail -n +2: creer un pseudo fichier qui commence par la 2e ligne du texte original
        # 2. paste -d ' ' leftfile rightfile, combine chaque ligne de leftfile et chaque ligne de rightfile , separé par l'espace , alors "$file" est leftfile,  - indique le pseudo fichier qui est le rightfile
        # 3. head -n -1: supprime la derniere ligne, pcq y a pas de mot après
        # https://www.runoob.com/linux/linux-comm-paste.html
        tail -n +2 "$tokenisation_path" | paste -d ' ' "$tokenisation_path" - | head -n -1 > "$bigrammes_path"
    fi

done < $tsv