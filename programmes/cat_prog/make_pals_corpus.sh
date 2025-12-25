#!/bin/bash

# Prends tous les unigrammes tokenisés catalans et les agrège dans un fichier
cat ./tokenisation/cat_tokenisation/dumps_tokenisation/*.txt > "./pals/dumps-text-cat.txt"
cat ./tokenisation/cat_tokenisation/contextes_tokenisation/*.txt > "./pals/contextes-cat.txt"

# Analyse la spécificité de Lafon pour les cooccurrents de "xarxa" (ou "xarxes") situés jusqu'à 5 tokens avant ou après le mot cible.
# Affiche le tout en colonnes au format txt (en utilisant la commande "column") et au format csv (en utilisant la commande "cut") pour faciliter la conversion en HTML (voir plus bas)
python ./programmes/cooccurrents.py --target "(xarxa|xarxes)" -s i -l 5 -N 50 --match-mode regex ./pals/pals_cat/dumps-text-cat.txt | column -t -s $'\t' > pals/pals_cat/cooccurents-dumps-text-cat.txt
python ./programmes/cooccurrents.py --target "(xarxa|xarxes)" -s i -l 5 -N 50 --match-mode regex ./pals/pals_cat/contextes-cat.txt | column -t -s $'\t' > pals/pals_cat/cooccurents-contextes-cat.txt
python ./programmes/cooccurrents.py --target "(xarxa|xarxes)" -s i -l 5 -N 50 --match-mode regex ./pals/pals_cat/dumps-text-cat.txt | cut -f 1- --output-delimiter ',' > pals/pals_cat/cooccurents-dumps-text-cat.csv
python ./programmes/cooccurrents.py --target "(xarxa|xarxes)" -s i -l 5 -N 50 --match-mode regex ./pals/pals_cat/contextes-cat.txt | cut -f 1- --output-delimiter ',' > pals/pals_cat/cooccurents-contextes-cat.csv

# Présente les résultats au format HTML
html_path="./pals/pals_cat/index.html"
cat << EOF > "$html_path"
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
EOF
# les titres de colones sont sur la première ligne du fichier CSV (head -n 1) en séparant les colonnes du csv par des balises html <tr><th>
cat pals/pals_cat/cooccurents-dumps-text-cat.csv | head -n 1 | sed 's/^/<tr><th>/' | sed 's/,/<\/td><th>/g' | sed 's/,/<\/th><th>/g' >> "$html_path"
cat << EOF >> "$html_path"
                    </thead>
					<tbody>
EOF
# on ignore les titres de colones sont sur la première ligne du fichier CSV (tail -n +2) en séparant les colones du csv par des balises <tr><td>
cat pals/pals_cat/cooccurents-dumps-text-cat.csv | tail -n +2 | sed 's/^/<tr><td>/' | sed 's/,/<\/td><td>/g' | sed 's/$/<\/td><\/tr>/' >> "$html_path"
cat << EOF >> "$html_path"
                    </tbody>
                </table>
            </div>
        </section>
    </body>
</html>
EOF

