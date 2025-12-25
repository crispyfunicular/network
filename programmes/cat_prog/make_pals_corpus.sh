#!/bin/bash

# Prends tous les unigrammes tokenisés catalans et les agrège dans un fichier
cat ./tokenisation/cat_tokenisation/dumps_tokenisation/*.txt > "./pals/dumps-text-cat.txt"
cat ./tokenisation/cat_tokenisation/contextes_tokenisation/*.txt > "./pals/contextes-cat.txt"

# Analyse la spécificité de Lafon pour les cooccurrents de "xarxa" (ou "xarxes") situés jusqu'à 5 tokens avant ou après le mot cible.
# Affiche le tout en colonnes
python ./programmes/cooccurrents.py --target "(xarxa|xarxes)" -s i -l 5 --match-mode regex ./pals/pals_cat/dumps-text-cat.txt | column -t -s $'\t' | head -n 50 > pals/pals_cat/cooccurents-dumps-text-cat.txt
python ./programmes/cooccurrents.py --target "(xarxa|xarxes)" -s i -l 5 --match-mode regex ./pals/pals_cat/contextes-cat.txt | column -t -s $'\t' | head -n 50 > pals/pals_cat/cooccurents-contextes-cat.txt