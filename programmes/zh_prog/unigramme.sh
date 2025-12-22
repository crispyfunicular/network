#!/bin/bash

# Forcer l'encodage UTF-8 pour éviter que sed/tr ne corrompe les caractères chinois
# parceque j'ai constaté que,les caracteres chinois sont encodés par 3 octets en utf8,
# mais le decodage par defaut(peut-etre 8-bits table) en bash avec sed et tr a mal interpreté.
export LANG=en_US.UTF-8

#Transforme les token_textes en CoNLL(format vertical)
#pour les etapes suivante avec PALs, qui recoit les tokenizations sous format 'minimalistic CoNLL' - one token per line.

tokenisation_dir="../../tokenisation/zh"
unigramme_dir="../../unigrammes/zh"

mkdir -p "$unigramme_dir"

echo "Commencer à mettre le token_texte en CoNLL..."

for tokenfile in "$tokenisation_dir"/*.txt; do
    id=$(basename "$tokenfile" _token.txt)
    uni_token="${id}_unigramme.txt"

    cat "$tokenfile" | \
    # effacer les ponctuation 'anglaises'
    sed -E 's/[[:punct:]]//g' | \
    #effacer les ponctuation 'chinoises'
    sed -E 's/[，。、；：？！～{}=+-«»“”‘’（）…—《》]//g' | \
    # -s pour les espaces continus, on les remplace par une saute de ligne
    # sinon, les espaces continus devienent plusieurs \n
    tr -s ' ' '\n'  | \
    # effacer les lignes vides
    grep -v "^$" > "$unigramme_dir/$uni_token"

done

echo "C'est bon!"
