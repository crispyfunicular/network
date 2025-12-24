#!/bin/bash

# Forcer l'encodage UTF-8 pour éviter que sed/tr ne corrompe les caractères chinois
# parceque j'ai constaté que,les caracteres chinois sont encodés par 3 octets en utf8,
# mais le decodage par defaut(peut-etre 8-bits table) en bash avec sed et tr a été mal interpreté.
export LANG=en_US.UTF-8

if ! python3 -c "import thulac" &> /dev/null; then
    echo "Error : La bibliothèque 'thulac' n'est pas installée."
    echo "Veuillez l'installer manuellement avec l'une des commandes :"
    echo "   pip install thulac  ou  uv pip install thulac "
    echo "Une fois l'installation terminée, relancez ce script."
    exit 1
fi



# les chemins vers les fichier en tant que l'entrée
DUMP_DIR="../../dumps-text/zh_dumps"
CONTEXT_DIR="../../contextes/zh"

#les chemins de sorties (resultat)
CONTEXT_TOKENISATION_DIR="../../tokenisation/zh_tokenisation/context_tokenisation"
DUMP_TOKENISATION_DIR="../../tokenisation/zh_tokenisation/dump_tokenisation"


mkdir -p "$CONTEXT_TOKENISATION_DIR"
mkdir -p "$DUMP_TOKENISATION_DIR"


echo "Commencement de la chaîne de traitement : Tokenisation -> Format CoNLL"


# Traitement des DUMP TEXTS
for file in "$DUMP_DIR"/*.txt; do

    # 1. obetenir le nom du fichier sortie:
    # comme j'ai gardé qq urls sans resultat, alors il manque le dump_text correspendant au numéro de ce urls
    # pour assurer la coherence entre la numérotation et le nom des fichiers de token et dump, on utilise la commande `basename`
    id=$(basename "$file" .txt)
    dump_uni_token="${id}_dump_unigramme.txt"


    # Pipeline: Python -> Sed -> Tr -> Grep -> Sortie
    # 2. tokenisation les textes chinois par un script en python
    python3 tokenize_chinese.py < "$file" | \

    # 3. transforme en format CoNLL(un token par ligne)
    #  nettoyer les ponctuation 'anglaises'
    sed -E 's/[[:punct:]]//g' | \
    # nettoyer les ponctuation 'chinoises'
    sed -E 's/[，。、；：？！～{}=+-«»“”‘’（）…—《》]//g' | \
    # -s pour les espaces continus, on les remplace par une saute de ligne
    # sinon, les espaces continus devienent plusieurs \n
    tr -s ' ' '\n' | \
    # effacer les lignes vides
    grep -v "^$" > "$DUMP_TOKENISATION_DIR/$dump_uni_token"

    echo "Traitement de ce dump_texte est fini : $dump_uni_token ..."
done

# pour les textes de contexte, on fait la meme chose
for context_file in "$CONTEXT_DIR"/*.txt; do
    id=$(basename "$context_file" .txt)
    context_uni_token="${id}_context_unigramme.txt"

    python3 tokenize_chinese.py < "$context_file" | \
    sed -E 's/[[:punct:]]//g' | sed -E 's/[，。、；：？！～{}=+-«»“”‘’（）…—《》]//g' | \
    tr -s ' ' '\n' | grep -v "^$" > "$CONTEXT_TOKENISATION_DIR/$context_uni_token"

    echo "Traitement de ce context_texte est fini : $context_uni_token ..."
done

echo "C'est fini la tokenisation et la conversion en CoNLL!"

# ==========================================================================
echo "Nous allons commencer à fuisonner ces fichiers et créer les pals corpus de ces deux parties."
PALS_DIR="../../pals/pals_zh"
mkdir -p "$PALS_DIR"
# chemin de sorite
DUMP_OUTPUT_FILE="$PALS_DIR/dumps-text-zh.txt"
CONTEXT_OUTPUT_FILE="$PALS_DIR/contextes-zh.txt"

cat "$DUMP_TOKENISATION_DIR"/*.txt > "$DUMP_OUTPUT_FILE"
echo "La creation de 'pals dumps corpus' en CoNLL est finie!"

cat "$CONTEXT_TOKENISATION_DIR"/*.txt > "$CONTEXT_OUTPUT_FILE"
echo "La creation de 'pals contexte corpus' en CoNLL est finie!"

