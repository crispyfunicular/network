# Programme de Traitement et Analyse de URLs(Corpus Chinois)

Ce dossier regroupe un ensemble de scripts (Bash et Python) destinés au traitement automatique d‘une liste des URLs pour créer un tableau HTML et un corpus de textes en chinois.

Les principales fonctionnalités incluent :
- **Collection des textes** à partir des URLs et création d'un tableau récapitulatif.
- **Tokenisation** du texte chinois avec la librairie `thulac`.
- **Transformation** au format CoNLL (un token par ligne).
- **Génération de Bigrammes**.
- **Création de Concordanciers et Concordanciers avec coloration** .
- **Analyse textométrique avec PALS** .
- **Visualisation** sous forme de **Nuages de mots** (Wordclouds).

---

## Structure des Dossiers

Les scripts de ce projet utilisent des **chemins relatifs** (ex: `../../dumps-text`).
Pour garantir le bon fonctionnement des scripts, il est **impératif** de respecter l'arborescence suivante :

```text
RACINE_DU_PROJET/
├── tableaux/              <-- Tableaux HTML générés
├── dumps-text/            <-- Fichiers textes bruts (dumps)
│   └── zh_dumps/          <-- Vos fichiers .txt ici
├── contextes/             <-- Fichiers de contextes
│   └── zh/                <-- Vos fichiers .txt ici
├── pals/                  <-- Résultats de l'analyse PALS
│   └── pals_zh/
├── tokenisation/          <-- Fichiers segmentés (CoNLL)
│   └── zh_tokenisation/
├── bigrammes/             <-- Listes de bigrammes
│   └── zh_bigrammes/
└── programmes/
    ├── cooccurrents.py    <-- Scripts Python PALS
    ├── partition.py
    └── zh_prog/           <-- TOUS LES SCRIPTS DOIVENT ÊTRE ICI
        ├── traitement_url_base.sh
        ├── tokenisation_zh.sh
        ├── pals_analyse.sh
        ├── bigramme.sh
        ├── make_cordonance_zh.sh
        ├── make_color_concordance.sh
        ├── tokenize_chinese.py
        └── NotoSansCJK-Regular.ttc (Fichier de police)

```

> **Note :** Ne renommez pas les dossiers principaux (`dumps-text`, `contextes`, `pals`), sinon les scripts ne trouveront plus les fichiers.

---

## Pré-requis et Installation

### 1. Environnement Python

Le projet nécessite **Python 3**. Installez les dépendances avec la commande suivante :

```bash
pip install thulac wordcloud
```

### 2. Police de caractères (Pour les nuages de mots)

Pour générer des nuages de mots en chinois sans erreurs d'affichage (carrés vides), vous devez placer un fichier de police compatible (ex: `NotoSansCJK-Regular.ttc` ou `SimHei.ttf`) dans le dossier `programmes/zh_prog/`.

Assurez-vous que la variable `FONT_PATH` dans le script `pals_analyse.sh` pointe bien vers ce fichier.

---

## Guide d'Utilisation (Ordre d'exécution)

Veuillez exécuter les scripts dans l'ordre suivant depuis le terminal, en étant positionné dans le dossier `programmes/zh_prog/`.

### Étape 1 : Récupération des données et création du tableau

Ce script télécharge les pages, extrait le texte (dumps, contextes) et génère le tableau HTML initial.

```bash
bash traitement_url_base.sh
```

### Étape 2 : Tokenisation (Segmentation)

Ce script nettoie les textes, segmente les phrases en mots (avec `thulac`) et formate la sortie.

```bash
bash tokenisation_zh.sh
```

### Étape 3 : Génération des Bigrammes

Crée des listes de paires de mots consécutifs.

```bash
bash bigramme.sh
```

### Étape 4 : Concordancier

Génère les fichiers de concordance pour analyser le mot-cible en contexte.

```bash
bash make_cordonance_zh.sh
```

### Étape 5 : Analyse PALS et Nuages de Mots

Ce script lance l'analyse statistique et génère les images.

```bash
bash pals_analyse.sh
```

**Fonctionnalités du script PALS :**

* Calcule les cooccurrents du mot-cible.
* Compare les spécificités entre le corpus global (Dumps) et local (Contextes).
* Génère les images `.png` des nuages de mots (en excluant les "stopwords").

### Étape 6 : Coloration des concordances

Ce script vise à générer une version HTML des concordances colorées, où les mots du champ sémantique fort sont mis en évidence (colorés). Les mots du champ sémantique fort sont séléctionnés à partir des résultats de l'analyse PALS (fichier cooc_context.tsv) et exclut les termes à très faible co-fréquence ou non pertinents.

```bash
bash make_color_concordance.sh
```

> **Note :** Enfin, tous les résultats peuvent être consultés via le tableau HTML généré à l'étape 1 (`tableaux/`).

---

## Dépannage

Erreur : `ModuleNotFoundError: No module named 'thulac'

> Vous n'avez pas installé la librairie. Exécutez : `pip install thulac`.

Nuage de mots avec des carrés (□□□)

> Le chemin vers la police chinoise est incorrect. Ouvrez `pals_analyse.sh` et modifiez la variable `FONT_PATH` pour qu'elle pointe vers le fichier `.ttc` ou `.ttf` présent dans le dossier.

---

*M1 PluriTAL - 2025/2026*
