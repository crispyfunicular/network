#!/bin/bash

# Attention, ce script doit être appelé depuis la racine du projet, et non depuis le dossier où il se trouve.

echo "Etape 1: Aspiration des URL"
./programmes/cat_prog/get_URLs_cat.sh

echo ""
echo "Etape 2: Tokenisation"
./programmes/cat_prog/tokenisation.sh

echo ""
echo "Etape 3: Création des bigrammes"
./programmes/cat_prog/bigrammes.sh

echo ""
echo "Etape 4: Création des contextes"
./programmes/cat_prog/context.sh

echo ""
echo "Etape 5: Analyse textométrique"
./programmes/cat_prog/make_pals_corpus.sh

echo ""
echo "Etape 6: Création des concordanciers"
./programmes/cat_prog/concordancier.sh

echo ""
echo "Etape 7: Création du tableau HTML"
./programmes/cat_prog/generate_html.sh

echo ""
echo "Etape 8: Création du nuage de mots"
./programmes/cat_prog/wordcloud.sh