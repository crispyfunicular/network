#!/bin/bash

# concatène tous les fichiers tokenisés, filtre les tokens pour ne garder que les mots pertinents (suppression des stopwords via stopwords_cat_github.txt,
# exclusion du mot-cible xarxa|xarxes, suppression des mots très courts et des tokens contenant des chiffres), met tout en minuscules,
# puis écrit deux fois deux fichiers de tokens (.txt et .png)

# Le premier grep cherche et ignore les stopwords
# -w n'examine que les mots entiers -i ignore la casse -v supprime au lieu de filtrer -f indique le fichier contenant les patterns à chercher
# Le deuxième grep cherche les mots d'une seule lettre (typiquement: "s'", "d'"...)
# Le troisième grep cherche les mots contenant des chiffres (par exemple, les dates)
# Le tr remplace les majuscules par des minuscules
cat ./tokenisation/cat_tokenisation/dumps_tokenisation/*.txt | grep -F -w -v -i -f ./wordcloud/cat/stopwords_cat_github.txt | grep -v -E -i '(xarxa|xarxes)' | grep -v -E '^.{1,2}$' | grep -v -E '[0-9]' | tr '[:upper:]' '[:lower:]' > "./wordcloud/cat/wordcloud_tokens.txt"
cat ./tokenisation/cat_tokenisation/contextes_tokenisation/*.txt | grep -F -w -v -i -f ./wordcloud/cat/stopwords_cat_github.txt | grep -v -E -i '(xarxa|xarxes)' | grep -v -E '^.{1,2}$' | grep -v -E '[0-9]' | tr '[:upper:]' '[:lower:]' > "./wordcloud/cat/wordcloud_tokens_contextes.txt"

source venv/bin/activate
wordcloud_cli --text ./wordcloud/cat/wordcloud_tokens.txt --imagefile ./wordcloud/cat/wordcloud_dumps-text_cat.png
wordcloud_cli --text ./wordcloud/cat/wordcloud_tokens_contextes.txt --imagefile ./wordcloud/cat/wordcloud_contextes_cat.png