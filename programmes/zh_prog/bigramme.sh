#!/bin/bash

export LANG=en_US.UTF-8


unigramme_dir="../../unigrammes/zh"
bigramme_dir="../../bigrammes/zh"

mkdir -p "$bigramme_dir"

echo "En train de créer les Bigrammes..."

for file in "$unigramme_dir"/*.txt; do

    id=$(basename "$file" _unigramme.txt)
    bigramfile="${id}_bigramme.txt"

    # 1. tail -n +2: creer un pseudo fichier qui commence par la 2e ligne du texte original
    # 2. paste -d ' ' leftfile rightfile, combine chaque ligne de leftfile et chaque ligne de rightfile , separé par l'espace , alors "$file" est leftfile,  - indique le pseudo fichier qui est le rightfile
    # 3. head -n -1: supprime la derniere ligne, pcq y a pas de mot après
    # https://www.runoob.com/linux/linux-comm-paste.html
    tail -n +2 "$file" | paste -d ' ' "$file" - | head -n -1 > "$bigramme_dir/$bigramfile"

done

echo "C'est bon!"
