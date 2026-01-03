#!/usr/bin/env bash

# Vérification des arguments
if [ $# -ne 1 ]
then
    echo "Le script attend exactement un argument (le fichier d'URLs)"
    exit 1
fi

fichier_urls=$1

# En-tête du fichier principal
echo "<html>
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
                            <th class=\"has-text-white\">Numéro</th>
                            <th class=\"has-text-white\">URL</th>
                            <th class=\"has-text-white\">Code</th>
                            <th class=\"has-text-white\">Encodage</th>
                            <th class=\"has-text-white\">Nombre d'occurrences</th>
                            <th class=\"has-text-white\">Page HTML brut</th>
                            <th class=\"has-text-white\">Dump</th>
                            <th class=\"has-text-white\">Contextes</th>
                            <th class=\"has-text-white\">Concordancier</th>
                            <th class=\"has-text-white\">Bigrammes</th>
                            <th class=\"has-text-white\">Robots.txt</th>
                            <th class=\"has-text-white\">Concorcancier avec coloration</th>
                        </tr>
                    </thead>
                    <tbody>"

lineno=1
mot="red(es)?"

while read -r line
do
    # 1. Récupération des données et en-têtes
    data=$(curl -s -L -w "%{http_code}\n%{content_type}" -o ./.data.tmp "$line")
    http_code=$(echo "$data" | tail -n 2 | head -n 1)
    encoding=$(echo "$data" | tail -n 1 | grep -o "charset=[^ ;]*" | cut -d"=" -f2)

    if [ -z "${encoding}" ]; then encoding="UTF-8"; fi

    # 2. Robots.txt
    base_url=$(echo "$line" | grep -oE "https?://[^/]+")
    status_robots=$(curl -s -o /dev/null -L -w "%{http_code}" "${base_url}/robots.txt")

    if [ "$status_robots" -eq 200 ]; then
        robots_cell="<a href=\"${base_url}/robots.txt\" target=\"_blank\">robots.txt</a>"
    else
        robots_cell="Absence"
    fi

    noccurrences=""
    col_html=""
    col_dump=""
    col_contextes=""
    col_concordance=""
    col_bigrammes=""
    col_coloration=""

    if [ "$http_code" -eq 200 ]; then
        
        if echo "$encoding" | grep -ivq "UTF-8"; then
            iconv -f "$encoding" -t "UTF-8" ./.data.tmp > ./.data.utf8.tmp 2>/dev/null
            if [ $? -eq 0 ]; then
                mv ./.data.utf8.tmp ./.data.tmp
            fi
        fi

        # 3. Chemins d'accès aux fichiers
        chemin_aspiration="../../aspirations/es_aspirations/espagnol${lineno}.html"
        chemin_dump="../../dumps-text/es_dumps/espagnol${lineno}.txt"
        chemin_contextes="../../contextes/es/espagnol${lineno}.txt"
        chemin_concordance="../../concordances/es/espagnol${lineno}.html"
        chemin_bigrammes="../../bigrammes/es_bigrammes/espagnol${lineno}.html"

        # 4. aspiration dump
        lynx -dump -nolist -stdin < ./.data.tmp > "$chemin_dump"
        cp ./.data.tmp "$chemin_aspiration"

        # 5. Extraction de contextes
        grep -Ei -C 2 "\b$mot\b" "$chemin_dump" > "$chemin_contextes"

        # 6. Comptage des occurrences
        noccurrences=$(grep -Eio "\b$mot\b" "$chemin_dump" | wc -l)

        # 7. Génération du Concordancier
        echo "<html>
        <head>
            <meta charset=\"UTF-8\">
            <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css\">
        </head>
        <body>
            <table class=\"table is-bordered is-hoverable is-striped is-fullwidth\">
                <thead>
                    <tr>
                        <th>Contexte gauche</th>
                        <th>Mot</th>
                        <th>Contexte droit</th>
                    </tr>
                </thead>
                <tbody>" > "$chemin_concordance"

        grep -Eio "[^ ]*.{0,30}\b$mot\b.{0,30}[^ ]*" "$chemin_dump" | while read -r contexte
        do
            mot_trouve=$(echo "$contexte" | grep -Eio "\b$mot\b" | head -1)
            gauche=$(echo "$contexte" | sed "s/$mot_trouve.*//")
            droit=$(echo "$contexte" | sed "s/.*$mot_trouve//")
            echo "<tr><td align='right'>$gauche</td><td><b>$mot_trouve</b></td><td>$droit</td></tr>" >> "$chemin_concordance"
        done
        echo "</tbody></table></body></html>" >> "$chemin_concordance"

        # 8. Génération de bigrammes
        echo "<html>
        <head>
            <meta charset=\"UTF-8\">
            <link rel=\"stylesheet\" href=\"https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css\">
        </head>
        <body>
            <table class=\"table is-bordered is-hoverable is-striped is-narrow\">
                <tbody>" > "$chemin_bigrammes"

        words=$(cat "$chemin_dump" | perl -Mutf8 -pe '$_=lc($_)' | grep -oE "[a-záéíóúñü]+")

        if [ -n "$words" ]; then
            paste <(echo "$words" | sed '$d') <(echo "$words" | tail -n +2) | \
            awk '{print "<tr><td>" $1 " " $2 "</td></tr>"}' >> "$chemin_bigrammes"
        fi
        echo "</tbody></table></body></html>" >> "$chemin_bigrammes"

        col_html="<a href=\"../aspirations/es_aspirations/espagnol${lineno}.html\">HTML</a>"
        col_dump="<a href=\"../dumps-text/es_dumps/espagnol${lineno}.txt\">Dump</a>"
        col_contextes="<a href=\"../contextes/es/espagnol${lineno}.txt\">Contextes</a>"
        col_concordance="<a href=\"../concordances/es/espagnol${lineno}.html\">Concordance</a>"
        col_bigrammes="<a href=\"../bigrammes/es_bigrammes/espagnol${lineno}.html\">Bigrammes</a>"
        col_coloration="<a href=\"../concor_coloration/es/espagnol${lineno}.html\">Concor_coloration</a>"
    fi

    # 9. Écriture de la ligne dans la table principale
    echo "<tr>
        <td>$lineno</td>
        <td><a href=\"$line\">$line</a></td>
        <td>$http_code</td>
        <td>$encoding</td>
        <td>$noccurrences</td>
        <td>$col_html</td>
        <td>$col_dump</td>
        <td>$col_contextes</td>
        <td>$col_concordance</td>
        <td>$col_bigrammes</td>
        <td>$robots_cell</td>
        <td>$col_coloration</td>
    </tr>"

    lineno=$((lineno + 1))
done < "$fichier_urls"

echo "              </tbody>
            </table>
        </div>
    </section>
    </body>
</html>"