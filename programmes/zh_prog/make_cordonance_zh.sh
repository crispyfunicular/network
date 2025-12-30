#!/bin/bash

# Script vise à créer 'concordance-html' pour chaque url

MOT="网络"
DUMP_DIR="../../dumps-text/zh_dumps"
OUTPUT_DIR="../../concordances/zh"

mkdir -p "$OUTPUT_DIR"

echo "En train de créer le tableau-concordance pour chaque url"

# itérer tous les token_textes comme "1_token.txt"
for file in "$DUMP_DIR"/*.txt; do

    # Recuperer id (i.e. nom) du fichier
    filename=$(basename "$file")
    id=$(echo "$filename" | grep -oE "[0-9]+")

    concordance="$OUTPUT_DIR/$id-concord.html"

    echo "
    <html>
    <head>
        <meta charset=\"UTF-8\">
        <title>Tableau des URLs</title>
        <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
        <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css\">
    </head>
    <body>
        <section class=\"section\">
            <div class=\"table-container\">
                <table class=\"table is-bordered is-hoverable is-striped is-fullwidth\">
                    <thead class=\"has-background-info has-text-white\">
                        <tr>
                            <th class="has-text-centered">Contexte gauche</th>
                            <th class="has-text-centered">Mot cible</th>
                            <th class="has-text-centered">Contexte droit</th>
                        </tr>
                    </thead>" > "$concordance"
    # ================= ancienne methode avec sed =================================
    # <tr><td>right context </td><td> mot cible </td><td> left context </td></tr>
    # remplir le contenu de chaque ligne
    # pour une ligne où ce mot cible apparait, le debut de la ligne (^) et la fin de cette ligne ($) est remplacé par les balises du tableau
    # le mot cible est remplacé par  </td><td>mot-cible</td><td>, le chiffre \1 indique ce que on capture le groupe ($MOT)
            # grep "$MOT" "$file" | sed -E "s/($MOT)/<\/td><td>\1<\/td><td>/g" | sed "s/^/<tr><td>/" | sed "s/$/<\/td><\/tr>/" >> "$concordance"
    # mais cette methode a une limite, si le mot cible apparait deux fois dans une meme ligne.
    # ============================================================================


    # ====================== nouvelle methode ==============================
    # REFERENCE de la methode awk: https://wangchujiang.com/linux-command/c/awk.html

    # ALOR ICI, ON UTILISE ' AWK ' pour gérer les occurrences multiples. Si le mot apparaît 2 fois dans une ligne, cela crée 2 lignes du tableau
        # Par exemple, si le mot apparaît 2 fois : "AB cible1 CD cible2 EF"
        # On veut générer deux lignes distinctes dans le tableau HTML :
        # 1. (AB) (cible1) (CD cible2 EF)
        # 2. (AB cible1 CD) (cible2) (EF)
    # ======================================================================


    # awk lit le texte ligne par ligne. Pour chaque ligne lue :
    # -v k="$MOT" : on passe la variable bash $MOT à la variable awk 'k'
    awk -v k="$MOT" '{
        # $0 : récupérer le contenu entier de la ligne en cours
        ligne_text = $0;

        # la longueur du mot cible (nécessaire pour découper les chaînes ensuite)
        len = length(k);

        # initialiser la position de départ de la recherche (au début de la ligne)
        start = 1;

        # Fonctionnement de la boucle :
        # On utilise substr pour créer une sous-chaîne qui commence à "start" (ignorant le début déjà traité).
        # et puis match() cherche le premier mot cible (k) uniquement dans cette sous-chaîne restante.
        # Tant que match() trouve le mot cible (retourne une valeur non nulle), on entre dans la boucle.

        while (match(substr(ligne_text, start), k)) {

            # ==================================================
            # Calcul de la position absolue du PREMIERE CARACTERE du mot cible dans la ligne entiere :
            # RSTART est une variable automatique définie par awk qui contient la position de départ trouvée par match().
            # Attention : RSTART est relative à la sous-chaîne (le morceau coupé), pas à la ligne entiere.
            # Donc : Position Absolue = Point de départ (start) + Position Relative (RSTART) - 1 (ajustement d index)
            # ===================================================
            pos = start + RSTART - 1;

            # Extraction du left context (debut de la ligne entiere - caractere juste avant ce mot cible)
            left = substr(ligne_text, 1, pos - 1);

            # Extraction du right contexte (caractere juste apres ce mocible - la fin de cette ligne)
            right = substr(ligne_text, pos + len);

            # Remplissage une ligne du tableau :
            # Contexte Gauche + Mot cible (en rouge/gras) + Contexte Droit
            print "<tr><td class=\"has-text-right\" style=\"width:45%\">" left "</td><td class=\"has-text-danger has-text-centered has-text-weight-bold\">" k "</td><td class=\"has-text-left\ style=\"width:45%\">" right "</td></tr>";

            # Mise à jour de la position "start" pour la prochaine itération
            # On recommencera la recherche juste après le mot que on vient de traiter (pos + 1)
            start = pos + len;
        }
    }' "$file" >> "$concordance"

    echo "    </table>
            </body>
            </html>" >> "$concordance"
done

echo "c'est bon!"
