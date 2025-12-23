#!/bin/bash

# Prends tous les unigrammes tokenisés catalans et les agrège dans un fichier

cat ./tokenisation/cat_tokenisation/dumps_tokenisation/*.txt > "./pals/dumps-text-cat.txt"
cat ./tokenisation/cat_tokenisation/contextes_tokenisation/*.txt > "./pals/contextes-cat.txt"