#!/bin/bash

dump_dir="../../dumps-text/zh_dumps"
tokenisation_dir="../../tokenisation/zh"

mkdir -p "$tokenisation_dir"

echo "commencement de tokenizer les textes"

# parcourir tous les dump_texts
for file in "$dump_dir"/*.txt; do
    # comme j'ai gardé qq urls sans resultat, et il manque le dump_text correspendant au numéro de ce urls
    # pour assurer la coherence entre la numérotation et le nom des fichiers de token et dump, on utilise la commande `basename`

    #on obtient le nom(numero) du fichier dumptext
    id=$(basename "$file" .txt)

    # on donne un nom au fichier de tokentext comme '1_token.txt'
    token_filename="${id}_token.txt"

    echo "Tokenisation du texte: $token_filename"

    python3 tokenize_chinese.py < "$file" > "$tokenisation_dir/$token_filename"

done

echo "c'est fini！Voir les resultats"

