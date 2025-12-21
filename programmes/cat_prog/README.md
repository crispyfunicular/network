**!! Work in progress !!**

Outils pour la collecte et la mise en page d'URLs (cat)

Description
-
Ce dossier contient deux scripts Bash complémentaires pour :
- récupérer des informations HTTP et statistiques de pages web à partir d'une liste d'URL ;
- générer une page HTML (tableau) récapitulant ces informations.

Prérequis
-
- `bash`
- `curl` (pour récupérer les en-têtes HTTP)
- `lynx` (ou équivalent) pour extraire le texte et compter les mots : `lynx -dump -nolist`

Scripts
-
- `get_URLs_cat.sh` : lit un fichier contenant une liste d'URLs (une par ligne), teste chaque URL et écrit sur la sortie standard des lignes TSV contenant :
  1. numéro de ligne
  2. URL
  3. code de réponse HTTP
  4. charset (extrait du header Content-Type si présent)
  5. nombre de mots (obtenu via `lynx -dump -nolist` si le code HTTP indique OK)

  Usage :
  ```bash
  ./get_URLs_cat.sh <fichier_urls>
  # exemple : ./get_URLs_cat.sh ../URL/URL_cat.txt > ../tableaux/URLs.tsv
  ```

- `generate_html.sh` : lit un fichier TSV (par défaut `tableaux/URLs.tsv`) et produit sur la sortie standard une page HTML contenant un tableau récapitulatif. Chaque ligne TSV doit respecter le format produit par `get_URLs_cat.sh` (numéro, URL, code, charset, nombre_de_mots, séparés par des tabulations).

  Usage :
  ```bash
  ./generate_html.sh [fichier_tsv]
  # exemple : ./generate_html.sh ../tableaux/URLs.tsv > ../tableaux/tableau_cat.html
  # si aucun argument, le script utilise tableaux/URLs.tsv
  ```

Format d'entrée attendu
-
- Fichier d'URLs (pour `get_URLs_cat.sh`) : une URL par ligne.
- Fichier TSV (pour `generate_html.sh`) : lignes avec au moins cinq champs séparés par des tabulations :
  `lineno \t url \t response_code \t charset \t num_words`

Notes et améliorations possibles
-
- `get_URLs_cat.sh` vérifie le code HTTP via `curl -I` et ne calcule le nombre de mots que si le code commence par `2`.
- `generate_html.sh` génère une table HTML minimale et peut être étendu pour insérer des liens vers les dumps textuels, concordanciers, robots.txt, etc.
- Pour un grand nombre d'URL, pensez à paralléliser les requêtes (ex : `xargs -P` ou `parallel`).