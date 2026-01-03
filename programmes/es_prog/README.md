# Traitement et Analyse des URLs (Corpus Espagnol)

Ce dossier contient les scripts Bash nécessaires au traitement automatique des URLs pour le corpus espagnol. Le mot-cible analysé est **"red"** (et son pluriel **"redes"**).

Les scripts permettent de passer d'une liste d'URLs brute à une analyse structurée comprenant : tableaux récapitulatifs, concordanciers (simples et colorés), bigrammes et préparation pour l'analyse textométrique (PALS).

## Prérequis

Les scripts s'appuient sur les outils standards suivants :

* `bash`, `curl`, `grep`, `sed`
* `lynx` (pour le dump textuel)
* `perl` (pour la gestion des accents et la tokenisation lors des bigrammes)

**Note importante sur l'arborescence :**
Les scripts utilisent des chemins relatifs (ex: `../../aspirations`). Ils doivent être exécutés depuis leur dossier d'emplacement (`programmes/es_prog/`) pour fonctionner correctement avec la structure globale du projet (`dumps-text`, `concordances`, `tableaux`, etc.).

## Description des Scripts

### 1. `espagnol.sh` (Script Principal)

C'est le script central du traitement. Il prend en entrée un fichier contenant une liste d'URLs et effectue l'ensemble de la chaîne de traitement :

1. **Aspiration** : Télécharge le code HTML et vérifie les codes HTTP/Encodages.
2. **Dump** : Convertit le HTML en texte brut via `lynx`.
3. **Extraction** : Isole les contextes autour du motif `red(es)?` et compte les occurrences.
4. **Génération HTML** :
* Tableau principal récapitulatif.
* Concordanciers (contexte gauche, mot, contexte droit).
* Tableaux de bigrammes (paires de mots fréquents).
* Lien vers le fichier `robots.txt` si existant.


### 2. `concor_coloration_es.sh` (Enrichissement visuel)

Ce script intervient après la création des concordanciers. Il reprend les fichiers HTML générés par le script principal et applique un style CSS (rouge et gras) sur une liste définie de cooccurrents pertinents (ex: *telecomunicaciones, infraestructura, mantenimiento, fibra...*).

Cela permet de visualiser rapidement le champ lexical dominant autour du mot "red".


### 3. `make_pals_corpus_es.sh` (Préparation PALS)

Ce script utilitaire prépare les données brutes pour l'analyse textométrique (PALS). Il lit les fichiers textes d'un dossier donné et effectue une tokenisation verticale (un mot par ligne), en ne gardant que les caractères alphanumériques (y compris les accents espagnols *á, é, í, ó, ú, ñ, ü*).


## Ordre d'exécution conseillé

Pour régénérer l'ensemble des données espagnoles, exécutez les commandes dans cet ordre :

1. **Collecte et Tableau** : Lancez `espagnol.sh`.
2. **Coloration** : Lancez `concor_coloration_es.sh` pour mettre à jour les concordanciers avec les couleurs.
3. **Analyse** : Utilisez `make_pals_corpus_es.sh` si vous devez recréer le fichier d'entrée pour PALS.