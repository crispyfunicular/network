#!/bin/bash

MOT="网络"
# basé sur le fichier cooc_context.tsv, tiré par specificity décroissante
# exclusion des termes à très faible co-fréquence et des mots non pertinents pour garder que le champ sémantique fort.
HIGHLIGHT_REGEX="社交|神经|安全|人际|人脉|舆论|英语|数据处理|人际关系|直播|稳定|乱象|暴力|结构|营销|法治|文学|清朗|行业|应用|风险|攻击|犯罪|数据|铁路|市场|货运|无线|政策|交通|货运|发展|辟谣|普法|无线|现象|校友|技术|趋势|行为"
DUMP_DIR="../../dumps-text/zh_dumps"
OUTPUT_DIR="../../concor_coloration/zh"

mkdir -p "$OUTPUT_DIR"
echo "Concordance avec coloration..."

for file in "$DUMP_DIR"/*.txt; do
    # Extraction de l'ID du fichier
    filename=$(basename "$file")
    id=$(echo "$filename" | grep -oE "[0-9]+")
    color_concordance="$OUTPUT_DIR/$id-color-concord.html"

    # HTML entete
    echo "
        <html>
        <head>
            <meta charset=\"UTF-8\">
            <title>Concordance: $id</title>
            <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
            <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css\">
            <style>
                .context-highlight {
                    background-color: #ffeb3b;
                    color: #d32f2f;
                    font-weight: bold;
                    padding: 0 2px;
                    border-radius: 2px;
                }
                td { vertical-align: middle !important; }
            </style>
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
                        </thead>
                        <tbody>" > "$color_concordance"

    # =================AWK=================
    # Pareil, ici, au lieu de la methode sed, ON UTILISE ' AWK ' pour gérer les occurrences multiples. Si le mot apparaît 2 fois dans une ligne, cela crée 2 lignes du tableau
    # REFERENCE de la methode awk: https://wangchujiang.com/linux-command/c/awk.html
    # -v target="$MOT"  : passage du mot cible à awk
    # -v highlight="$HIGHLIGHT_REGEX" : passage de l'expression régulière pour le surlignage

    awk -v target="$MOT" -v highlight="$HIGHLIGHT_REGEX" '
    {
        ligne_text = $0;
        len = length(target);
        start = 1;

        # Boucle pour trouver toutes les occurrences du mot cible dans la ligne
        while (match(substr(ligne_text, start), target)) {
            # Calcul de la position absolue dans la ligne complète
            pos = start + RSTART - 1;

            # Extraction du contexte
            left_raw = substr(ligne_text, 1, pos - 1);
            right_raw = substr(ligne_text, pos + len);

            # SURLIGNAGE
            # gsub(regex, texte_remplacement, variable_cible)
                # Rechercher TOUTES les parties correspondant à regex dans la variable cible
                # Remplacer CHAQUE partie correspondante par le texte de remplacement
            # Remplacement des mots correspondants au regex par la balise spans
            # & représente le texte(mot) correspondant (conservation du mot original)
            gsub(highlight, "<span class=\"context-highlight\">&</span>", left_raw);
            gsub(highlight, "<span class=\"context-highlight\">&</span>", right_raw);

            #  Production dune ligne de tableau
            print "<tr><td class=\"has-text-right\" style=\"width:45%\">" left_raw "</td><td class=\"has-text-danger has-text-centered has-text-weight-bold\">" target "</td><td class=\"has-text-left\ style=\"width:45%\">" right_raw "</td></tr>";

            start = pos + len;
        }
    }' "$file" >> "$color_concordance"

    echo "
                </tbody>
            </table>
        </div>
    </section>
</body>
</html>" >> "$color_concordance"
done

echo "Concordance avec coloration créée avec succès !"
