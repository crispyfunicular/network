#!/bin/bash

# Attention, ce script doit être appelé depuis la racine du projet, et non depuis le dossier où il se trouve.

./programmes/cat_prog/get_URLs_cat.sh > ./tableaux/cat_tableaux/URLs.tsv
./programmes/cat_prog/cat_tokenisation.sh
./programmes/cat_prog/context.sh
./programmes/cat_prog/generate_html.sh > ./tableaux/cat_tableaux/tableau_cat.html
