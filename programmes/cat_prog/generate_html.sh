#!/bin/bash

# ./generate_html.sh ../tableaux/URLs.tsv > ../tableaux/tableau_cat.html

# lit le fichier `URLs.tsv` et produit un tableau récapitulatif en HTML, dont les colonnes affichées sont les suivantes :
# numéro, URL, robots.txt, code, charset, nombre_de_mots, occurrences, ainsi que des liens vers les fichiers générés
# (HTML brut, dump texte, concordancier, concordancier coloré, bigrammes).

# $# number of arguments passed to the program
#if [ $# -ne 1 ]
#then
#	echo "ce programme demande un argument"
#	exit 1
#fi

# $1 first argument passed to the program; "tableaux/URLs.tsv" by default
tsv=${1-tableaux/cat_tableaux/URLs.tsv}
output_path="./tableaux/cat_tableaux/tableau_cat.html"

# cat << EOF allows to print multiple lines at once
# Write the begining of the HTML file/table
cat << EOF > "$output_path"
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
				<table class="table is-hoverable is-bordered is-striped">
					
					<thead class=""has-background-primary-35 has-text-primary-35-invert"">
						<tr>
							<th scope="col">line no</th>
							<th scope="col">adresse html</th>
							<th scope="col">robots.txt</th>
							<th scope="col">response code</th>
							<th scope="col">charset</th>
							<th scope="col">word number</th>
							<th scope="col">occurrences</th>
							<th scope="col">page HTML brute</th>
							<th scope="col">dump textuel</th>
							<th scope="col">concordancier HTML</th>
							<th scope="col">concordancier couleurs</th>
							<th scope="col">bigrammes</th>
						</tr>
					</thead>

					<tbody>
EOF


while read -r line;
do
	# increment the line counter by 1	
	lineno=$(echo "$line" | cut -f 1)
	url=$(echo "$line" | cut -f 2)
	response_code=$(echo "$line" | cut -f 3)
	charset=$(echo "$line" | cut -f 4)
	num_words=$(echo "$line" | cut -f 5)
	num_occurences=$(echo "$line" | cut -f 6)
	

	# Write one table row (<tr>) for each line in fr.txt
	# When different than 200, the response code is red (class="has-text-danger")
	if ! [[ "$response_code" -eq 200 ]];
	then
		rc_class=' class="has-text-danger"'
		cat << EOF >> "$output_path"
						<tr>
							<td>$lineno</td>
							<td><a href="$url">$url</td>
							<td>
EOF
		# Only add links to robotxt files if they exist
		if [[ -f "robots-txt/cat/robotstxt/$lineno.txt" ]]
		then
			cat << EOF >> "$output_path"
									<a href="../../robots-txt/cat/robotstxt/$lineno.txt">robots.txt</a>
									<br/>
									<a href="../../robots-txt/cat/blocklist/$lineno.txt">blocklist</a>
EOF
		fi
		cat << EOF >> "$output_path"
							</td>
							<td${rc_class}>$response_code</td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
						</tr>
EOF
	else
		rc_class=''
		cat << EOF >> "$output_path"
							<tr>
								<td>$lineno</td>
								<td><a href="$url">$url</td>
								<td>
EOF
		# Only add links to robotxt files if they exist
		if [[ -f "robots-txt/cat/robotstxt/$lineno.txt" ]]
		then
			cat << EOF >> "$output_path"
									<a href="../../robots-txt/cat/robotstxt/$lineno.txt">robots.txt</a>
									<br/>
									<a href="../../robots-txt/cat/blocklist/$lineno.txt">blocklist</a>
EOF
		fi
		cat << EOF >> "$output_path"
								</td>
								<td${rc_class}>$response_code</td>
								<td>$charset</td>
								<td>$num_words</td>
								<td>$num_occurences</td>
								<td><a href="../../aspirations/cat_aspirations/$lineno.html">page HTML brute</a></td>
								<td><a href="../../dumps-text/cat_dumps/$lineno.txt">dump textuel</a></td>
								<td><a href="../../concordances/cat/$lineno.html">concordancier HTML</a></td>
								<td><a href="../../concor_coloration/cat/$lineno.html">concordancier couleurs</a></td>
								<td><a href="../../bigrammes/cat/$lineno.txt">bigrammes</a></td>
							</tr>
EOF
	fi


done < $tsv

# Write the end of the HTML table/file
cat << EOF >> "$output_path"
					</tbody>
				</table>
			</div>
		</section>
	</body>
</html>
EOF