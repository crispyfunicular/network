**!! Work in progress !!**

Outils pour la collecte et la mise en page d'URL (cat)

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
- `get_URLs_cat.sh` : lit un fichier contenant une liste d'URL (une par ligne), teste chaque URL et écrit sur la sortie standard des lignes TSV contenant :
  1. numéro de ligne
  2. URL
  3. code de réponse HTTP
  4. charset (extrait du header Content-Type si présent)
  5. nombre de mots (obtenu via `lynx -dump -nolist` si le code HTTP indique OK)

  Le script sauvegarde la source HTML de chaque page dans le dossier `aspirations` et le texte brut dans `dumps-text/cat_dumps/`.

- **1/ Aspiration des URL** - `get_URLs_cat.sh` : lit le fichier `URLs.tsv` et, pour chaque URL, nettoie les répertoires de sortie, vérifie (si possible) le robots.txt du site et marque l’URL comme « disallowed » si elle est interdite, puis récupère les métadonnées HTTP (code de réponse + charset), aspire la page HTML correspondant et génère un dump texte via lynx. Il calcule ensuite le nombre de mots et le nombre d’occurrences de xarxa|xarxes, et écrit une ligne récapitulative dans `URLs.tsv`.

- **2/ Tokenisation** - `tokenisation.sh` : lit le fichier `URLs.tsv`, récupère pour chaque ligne le numéro de document (lineno), puis remplace toute ponctuation ou caractère non alphanumérique par des espaces, en mettant un token par ligne après avoir convertir espaces et caractères de contrôle en retours à la ligne (= tokenisation). Le script nettoie au préalable les dossiers de sortie.

- **3/ Création des bigrammes** - `bigrammes.sh` : lit le fichier `URLs.tsv`, récupère pour chaque ligne le numéro de document (lineno), puis prend le fichier tokenisé correspondant et construit des bigrammes en associant chaque token avec le token suivant.

- **4/ Création des contextes** - `context.sh` : lit le fichier `URLs.tsv`, récupère pour chaque ligne le numéro de document (lineno), puis parcourt le dump texte associé pour extraire tous les passages contenant le mot-cible xarxa|xarxes. Pour chaque occurrence, le script conserve 2 lignes avant et 2 lignes.

- **5/ Analyse textométrique** - `make_pals_corpus.sh` :
  - Prend tous les unigrammes tokenisés catalans et les agrège dans un fichier
  - Analyse la spécificité de Lafon pour les cooccurrents de xarxa|xarxes situés jusqu'à 5 tokens avant ou après le mot cible.
  - Affiche le tout en colonnes au format txt (en utilisant la commande « column ») et au format csv (en utilisant la commande « cut ») pour faciliter la conversion en HTML (voir plus bas)
  - Présente les résultats au format HTML

- **6/ Création des concordanciers** - `concordancier.sh` : lit le fichier `URLs.tsv`, récupère pour chaque ligne le numéro de document (lineno) puis, à partir du dump texte et du fichier de contextes déjà produit, génère un concordancier HTML sous forme de tableau à trois colonnes (contexte gauche / mot cible / contexte droit) pour chaque URL.

- **7/ Création du tableau HTML** - `generate_html.sh` : lit le fichier `URLs.tsv` et produit un tableau récapitulatif en HTML, dont les colonnes affichées sont les suivantes : numéro, URL, robots.txt, code, charset, nombre_de_mots, occurrences, ainsi que des liens vers les fichiers générés (HTML brut, dump texte, concordancier, concordancier coloré, bigrammes).
  - **robots.txt** : pour chaque URL, le script ajoute (si disponibles) des liens vers les fichiers `robotstxt.txt` et `blocklist.txt`, correspondant au robots.txt récupéré pour le site et à la blocklist (liste des chemins Disallow) extraite du bloc User-agent: *.
  - **code** : le code HTTP issu de `URLs.tsv` ; si le code est différent de 200, il est affiché en rouge et les autres champs/liaisons « contenu » sont laissés vides (pas de page/dump/concordancier/bigrammes).
  - **charset / nombre_de_mots / occurrences** : repris directement depuis URLs.tsv quand le code HTTP vaut 200.

- **8/ Création du nuage de mots** - `wordcloud.sh` : concatène tous les fichiers tokenisés, filtre les tokens pour ne garder que les mots pertinents (suppression des stopwords via stopwords_cat_github.txt, exclusion du mot-cible xarxa|xarxes, suppression des mots très courts et des tokens contenant des chiffres), met tout en minuscules, puis écrit deux fois deux fichiers de tokens (.txt et .png) :
  - wordcloud/cat/wordcloud_tokens.txt (sur l’ensemble des dumps)
  - wordcloud/cat/wordcloud_tokens_contextes.txt (sur les contextes)  

  - wordcloud/cat/wordcloud_dumps-text_cat.png  
  - wordcloud/cat/wordcloud_contextes_cat.png  

- **9/ Lancement de tous les programmes** - `data_pipeline.sh` : script d'orchestration (pipeline) qui enchaîne plusieurs étapes : collecte d'URL (`get_URLs_cat.sh`), production des dumps textuels, tokenisation (`cat_tokenisation.sh`) et génération du tableau HTML (`generate_html.sh`).


Chemins et fichiers importants
-
- Entrées :
  - Liste d'URL : `URL/URL_cat.txt` (exemple)
- Sorties / intermédiaires :
  - Dumps textuels : `dumps-text/cat_dumps/` (fichiers .txt)
  - Fichiers tokenisés : `tokenisation/cat_tokenisation/` (fichiers .txt)
  - Tableaux HTML : `tableaux/cat_tableaux/tableau_cat.html`
  - TSV récapitulatif : `tableaux/cat_tableaux/URLs.tsv`

Usage rapide
- Exécuter la collecte d'URL et produire le TSV :
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
- Fichier d'URL (pour `get_URLs_cat.sh`) : une URL par ligne.
- Fichier TSV (pour `generate_html.sh`) : lignes avec au moins cinq champs séparés par des tabulations : `lineno \t url \t response_code \t charset \t num_words`

