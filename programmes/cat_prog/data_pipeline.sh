#!/bin/bash

# Attention, ce script doit être appelé depuis la racine du projet, et non depuis le dossier où il se trouve.

# Création et nettoyage des dossiers du projet
mkdir -p ./aspirations/cat_aspirations
rm -rf ./aspirations/cat_aspirations/*
mkdir -p ./contextes/cat
rm -rf ./contextes/cat/*
mkdir -p ./concordances/cat
rm -rf ./concordances/cat/*
mkdir -p ./dumps-text/cat_dumps
rm -rf ./dumps-text/cat_dumps/*
mkdir -p ./tokenisation/cat_tokenisation
rm -rf ./tokenisation/cat_tokenisation/*

./programmes/cat_prog/get_URLs_cat.sh > ./tableaux/cat_tableaux/URLs.tsv
./programmes/cat_prog/cat_tokenisation.sh
./programmes/cat_prog/context.sh
./programmes/cat_prog/concordancier.sh
./programmes/cat_prog/generate_html.sh > ./tableaux/cat_tableaux/tableau_cat.html
