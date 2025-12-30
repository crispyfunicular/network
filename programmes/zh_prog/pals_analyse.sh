#!/bin/bash



PALS_DATA_DIR="../../pals/pals_zh"
CLOUD_DIR="../../wordcloud/zh"
STOPWORDS_FILE="../../pals/pals_zh/corpus_based_stopwords.txt"
TARGET_WORD="网络"

# Chemin vers le fichier de police pour le chinois
# C'est obligatoire pour le nuage de mots, sinon les caractères s'afficheront sous forme de carrés vides 'tofu'.
FONT_PATH="./NotoSansCJK-Regular.ttc"

# Vérifie si le fichier de police existe bien.
# Si le fichier est manquant, on affiche un avertissement pour prévenir l'utilisateur.
if [ ! -f "$FONT_PATH" ]; then
    echo "Attention : Le fichier de police est introuvable."
    echo "Le nuage de mots chinois risque d'être illisible (affichage de carrés)."
fi


echo "Commencement de l'analyse ：PALS + WORDCLOUD"

# 1. Cooccurrents
echo " COOCCURRENT Dumps ..."
python3 "../cooccurrents.py" "$PALS_DATA_DIR/dumps-text-zh.txt" \
    --target "$TARGET_WORD" -N 100 -s i > "$PALS_DATA_DIR/dump_cooc.tsv"

echo " COOCCURRENT Contextes ..."
python3 "../cooccurrents.py" "$PALS_DATA_DIR/contextes-zh.txt" \
    --target "$TARGET_WORD" -N 100 -s i > "$PALS_DATA_DIR/context_cooc.tsv"

# 2. Partition
echo " Partition (Dump vs Context)..."
python3 "../partition.py" -i "$PALS_DATA_DIR/dumps-text-zh.txt" -i "$PALS_DATA_DIR/contextes-zh.txt" \
    > "$PALS_DATA_DIR/partition_comparison.tsv"

echo "C'est fini pour pals"


# Nuage de mots

echo "Nuage de mots ..."

# check l'installation de wordcloud_cli
if ! command -v wordcloud_cli &> /dev/null; then
    echo "error: wordcloud_cli not found. Please install : uv pip install wordcloud"
    exit 1
fi

echo " Wordcloud - Dump ..."
wordcloud_cli \
    --text "$PALS_DATA_DIR/dumps-text-zh.txt" \
    --imagefile "$CLOUD_DIR/dumps_wordcloud.png" \
    --stopwords "$STOPWORDS_FILE" --fontfile "$FONT_PATH" \
    --background white --width 800 --height 600 \
    --max_words 35



echo " Wordcloud - Context ..."
wordcloud_cli \
    --text "$PALS_DATA_DIR/contextes-zh.txt" \
    --imagefile "$CLOUD_DIR/contextes_wordcloud.png" \
    --stopwords "$STOPWORDS_FILE" --fontfile "$FONT_PATH" \
    --background white --width 800 --height 600 \
    --max_words 35


echo "Tout est fini!"
