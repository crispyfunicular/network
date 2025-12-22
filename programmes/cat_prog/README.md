**!! Work in progress !!**

Outils pour la collecte et la mise en page d'URLs (cat)

Description
-
Ce dossier contient plusieurs scripts Bash complémentaires pour :
- récupérer des informations HTTP et statistiques de pages web à partir d'une liste d'URL ;
- générer une page HTML (tableau) récapitulant ces informations ;
- produire des dumps textuels et leurs versions tokenisées.

Prérequis
-
- `bash`
- `curl` (pour récupérer les en-têtes HTTP)
- `lynx` (ou équivalent) pour extraire le texte et compter les mots : `lynx -dump -nolist`

Remarque
-
- Toujours lancer les scripts depuis la racine du dépôt. Les exemples d'usage ci-dessous présupposent que vous êtes dans la racine du projet.

Scripts
-
- `get_URLs_cat.sh` : lit un fichier contenant une liste d'URLs (une par ligne), teste chaque URL et écrit sur la sortie standard des lignes TSV contenant :
  1. numéro de ligne
  2. URL
  3. code de réponse HTTP
  4. charset (extrait du header Content-Type si présent)
  5. nombre de mots (obtenu via `lynx -dump -nolist` si le code HTTP indique OK)

  Le script sauvegarde la source HTML de chaque page dans le dossier `aspirations` et le texte brute dans `dumps-text/cat_dumps/`.

- `generate_html.sh` : lit un fichier TSV (par défaut `tableaux/cat_tableaux/URLs.tsv`) et produit sur la sortie standard une page HTML contenant un tableau récapitulatif. Chaque ligne TSV doit respecter le format produit par `get_URLs_cat.sh` (numéro, URL, code, charset, nombre_de_mots, séparés par des tabulations).

- `cat_tokenisation.sh` : script de tokenisation pour les textes bruts. Il lit les fichiers de `dumps-text/cat_dumps/` et écrit les sorties tokenisées dans `tokenisation/cat_tokenisation/` (un fichier tokenisé par document).

- `data_pipeline.sh` : script d'orchestration (pipeline) qui enchaîne plusieurs étapes : collecte d'URLs (`get_URLs_cat.sh`), production des dumps textuels, tokenisation (`cat_tokenisation.sh`) et génération du tableau HTML (`generate_html.sh`). Utile pour exécuter le flux complet en une commande.

Chemins et fichiers importants
-
- Entrées :
  - Liste d'URLs : `URL/URL_cat.txt` (exemple)
- Sorties / intermédiaires :
  - Dumps textuels : `dumps-text/cat_dumps/` (fichiers .txt)
  - Fichiers tokenisés : `tokenisation/cat_tokenisation/` (fichiers .txt)
  - Tableaux HTML : `tableaux/cat_tableaux/tableau_cat.html`
  - TSV récapitulatif : `tableaux/cat_tableaux/URLs.tsv`

Usage rapide
- Exécuter la collecte d'URLs et produire le TSV :
  ```bash
  ./programmes/cat_prog/get_URLs_cat.sh <fichier_urls> > tableaux/cat_tableaux/URLs.tsv
  # exemple : ./programmes/cat_prog/get_URLs_cat.sh URL/URL_cat.txt > tableaux/cat_tableaux/URLs.tsv
  ```

- Générer la page HTML à partir du TSV :
  ```bash
  ./programmes/cat_prog/generate_html.sh tableaux/cat_tableaux/URLs.tsv > tableaux/cat_tableaux/tableau_cat.html
  ```

 - Lancer la tokenisation :
  ```bash
  ./programmes/cat_prog/cat_tokenisation.sh
  # lit dumps-text/cat_dumps/* et écrit tokenisation/cat_tokenisation/* (exécution depuis la racine)
  ```

 - Pipeline complet (exécute l'enchaînement des étapes) :
  ```bash
  ./programmes/cat_prog/data_pipeline.sh
  ```

Format d'entrée attendu
-
- Fichier d'URLs (pour `get_URLs_cat.sh`) : une URL par ligne.
- Fichier TSV (pour `generate_html.sh`) : lignes avec au moins cinq champs séparés par des tabulations : `lineno \t url \t response_code \t charset \t num_words`

Notes et améliorations possibles
-
- `get_URLs_cat.sh` vérifie le code HTTP via `curl -I` et ne calcule le nombre de mots que si le code commence par `2`.
- `generate_html.sh` génère une table HTML minimale ; il est possible d'ajouter des liens vers les dumps textuels et les fichiers tokenisés.
- Les scripts utilisent des chemins relatifs vers les dossiers à la racine du dépôt : adaptez-les si vous changez l'organisation du dépôt.
- Pour un grand nombre d'URL, privilégiez la parallélisation (ex : `xargs -P`, `parallel`) et un traitement par lots pour la tokenisation.
