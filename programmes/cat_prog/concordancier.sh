#!/bin/bash

# Récupère pour chaque URL le contexte avant et après le mot cible ("xarxa" ou "xarxes"), correspondant aux deux lignes précédant et suivant le mot cible.
# Entrée : liste d'URL + métadonnées au format tsv
# Sortie : Un fichier HTML par URL contenant le concordancier décrit dans le fichier https://github.com/YoannDupont/PPE1-2526/blob/main/exercices/concordancier.pdf

# ./programmes/cat_prog/concordancier.sh ../tableaux/URLs.tsv

# $1 first argument passed to the program; "tableaux/URLs.tsv" by default
tsv=${1-tableaux/cat_tableaux/URLs.tsv}


while read -r line;
do

	# increment the line counter by 1	
	lineno=$(echo "$line" | cut -f 1)

    dump_path="./dumps-text/cat_dumps/$lineno.txt"
    if [[ -f "$dump_path" ]]
    then
        # display each line in the stderr
	    echo "Getting context $dump_path" 1>&2
        concordances_path="./concordances/cat/$lineno.html"
        cat << EOF > "$concordances_path"
<html>
	<head>
		<meta charset="UTF-8"/>
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css">
		<title>xarxa</title>
	</head>

	<body>
		<section class="section">
			<div class="table-container">
                <table class="table is-bordered is-hoverable is-striped is-fullwidth">
                    <thead class="has-background-info has-text-white">
                        <tr>
                            <th>Left Context</th>
                            <th>Cible</th>
                            <th>Right Context</th>
                        </tr>
                    </thead>
					<tbody>
EOF
        cat "./contextes/cat/$lineno.txt" | sed -n 's/^\(.*\)\([xX]arxa\|[xX]arxes\)\(.*\)$/<tr><td>\1<\/td><td>\2<\/td><td>\3<\/td><\/tr>/p' >> "$concordances_path"
        cat << EOF >> "$concordances_path"
                    </tbody>
                </table>
            </div>
        </section>
    </body>
</html>
EOF
    fi

done < $tsv

