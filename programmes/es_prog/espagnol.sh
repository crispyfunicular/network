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
    </head>
    <body>
        <table>
            <thead>
                <tr>
                    <th>Numéro</th>
                    <th>URL</th>
                    <th>Code</th>
                    <th>Encodage</th>
                    <th>Nombre d'occurrences</th>
                    <th>Page HTML brut</th>
                    <th>Dump</th>
                    <th>Contextes</th>
                    <th>Concordancier</th>
                    <th>Bigrammes</th>
                    <th>Robots.txt</th>
                    <th>Concorcancier avec coloration</th>
                </tr>
            </thead>
            <tbody>"

lineno=1
mot="red(es)?"

while read -r line
do

    # 1. Récupération des données et en-têtes
    data=$(curl -s -L -w "%{http_code}\n%{content_type}" -o ./.data.tmp "$line")
    http_code=$(echo "$data" | head -1)
    encoding=$(echo "$data" | tail -1 | grep -o "charset=[^ ;]*" | cut -d"=" -f2)

    if [ -z "${encoding}" ]; then encoding="N/A"; fi

    # 2. Robots.txt
    base_url=$(echo "$line" | grep -oE "https?://[^/]+")
    status_robots=$(curl -s -o /dev/null -L -w "%{http_code}" "${base_url}/robots.txt")

    if [ "$status_robots" -eq 200 ]; then
        robots_cell="<a href=\"${base_url}/robots.txt\" target=\"_blank\">robots.txt</a>"
    else
        robots_cell="Absence"
    fi

    # 3. Chemins d'accès aux fichiers
    chemin_aspiration="../../aspirations/es_aspirations/espagnol${lineno}.html"
    chemin_dump="../../dumps-text/es_dumps/espagnol${lineno}.txt"
    chemin_contextes="../../contextes/es/espagnol${lineno}.txt"
    chemin_concordance="../../concordances/es/espagnol${lineno}.html"
    chemin_bigrammes="../../bigrammes/es_bigrammes/espagnol${lineno}.html"
    chemin_colorarion="../../concor_colorarition/es_coloration/espagnol${lineno}.html"

    # 4. aspiration dump
    lynx -dump -nolist -stdin < ./.data.tmp > "$chemin_dump"
    mv ./.data.tmp "$chemin_aspiration"

    # 5. Extraction de contextes
    grep -Ei -C 2 "\b$mot\b" "$chemin_dump" > "$chemin_contextes"

    # 6. Comptage des occurrences
    noccurrences=$(grep -Eio "\b$mot\b" "$chemin_dump" | wc -l)

    # 7. Génération du Concordancier
    echo "<html><head><meta charset='UTF-8'></head><body><table>
        <thead><tr><th>Contexte gauche</th><th>Mot</th><th>Contexte droit</th></tr></thead><tbody>" > "$chemin_concordance"

    grep -Eio "[^ ]*.{0,30}\b$mot\b.{0,30}[^ ]*" "$chemin_dump" | while read -r contexte
    do
        mot_trouve=$(echo "$contexte" | grep -Eio "\b$mot\b" | head -1)
        gauche=$(echo "$contexte" | sed "s/$mot_trouve.*//")
        droit=$(echo "$contexte" | sed "s/.*$mot_trouve//")
        echo "<tr><td align='right'>$gauche</td><td><b>$mot_trouve</b></td><td>$droit</td></tr>" >> "$chemin_concordance"
    done
    echo "</tbody></table></body></html>" >> "$chemin_concordance"

    # 8. Génération de bigrammes
    echo "<html><head><meta charset='UTF-8'></head><body><table>
        <tbody>" > "$chemin_bigrammes"

    words=$(cat "$chemin_dump" | perl -Mutf8 -pe '$_=lc($_)' | grep -oE "[a-záéíóúñü]+")

    if [ -n "$words" ]; then
        paste <(echo "$words" | sed '$d') <(echo "$words" | tail -n +2) | \
        awk '{print "<tr><td>" $1 " " $2 "</td></tr>"}' >> "$chemin_bigrammes"
    fi
    echo "</tbody></table></body></html>" >> "$chemin_bigrammes"

    # 9. Écriture de la ligne dans la table principale
    echo "<tr>
        <td>$lineno</td>
        <td><a href=\"$line\">$line</a></td>
        <td>$http_code</td>
        <td>$encoding</td>
        <td>$noccurrences</td>
        <td><a href=\"$chemin_aspiration\">HTML</a></td>
        <td><a href=\"$chemin_dump\">Dump</a></td>
        <td><a href=\"$chemin_contextes\">Contextes</a></td>
        <td><a href=\"$chemin_concordance\">Concordance</a></td>
        <td><a href=\"$chemin_bigrammes\">Bigrammes</a></td>
        <td>$robots_cell</td>
		<td><a href=\"$chemin_colorarion\">Concor_coloration</a></td>
    </tr>"

    lineno=$((lineno + 1))
done < "$fichier_urls"

echo "      </tbody>
        </table>
    </body>
</html>"
