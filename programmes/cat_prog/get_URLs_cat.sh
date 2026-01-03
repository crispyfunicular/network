#!/bin/bash

# lit le fichier `URLs.tsv` et, pour chaque URL,
# nettoie les répertoires de sortie, vérifie (si possible) le robots.txt du site
# et marque l’URL comme « disallowed » si elle est interdite,
# puis récupère les métadonnées HTTP (code de réponse + charset),
# aspire la page HTML correspondant et génère un dump texte via lynx.
# Il calcule ensuite le nombre de mots et le nombre d’occurrences de xarxa|xarxes,
# et écrit une ligne récapitulative dans `URLs.tsv`.

# $1 first argument passed to the program
URL=${1-URL/URL_cat.txt}

# Ouput file
tsv="./tableaux/cat_tableaux/URLs.tsv"
rm -f "$tsv"

# Cleaning of the aspiration directory
mkdir -p ./aspirations/cat_aspirations
rm -rf ./aspirations/cat_aspirations/*

# Cleaning of the dumps-text directory
mkdir -p ./dumps-text/cat_dumps
rm -rf ./dumps-text/cat_dumps/*

# Cleaning of the robot-txt directory
mkdir -p ./robots-txt/cat/robotstxt
mkdir -p ./robots-txt/cat/blocklist
rm -rf ./robots-cat/cat/robotstxt/*
rm -rf ./robots-cat/cat/blocklist/*

# total number of URLs to process
total=$(wc -l $URL | cut -d ' ' -f 1)

# counter for the line number of the urls file
lineno=0
while read -r line;
do

	# increment the line counter by 1
	lineno=$(expr $lineno + 1)

	# display the current counter and each URL in the stderr
	echo "$lineno/$total: Fetching $line" 1>&2

	###
	# robots.txt
	###

	# Adds "robots.txt" after each URL's root
	robot_URL=$(echo "$line" | sed -n 's/^\(https\?:\/\/[^\/]*\/\).*$/\1robots.txt/p')

	# Try to fetch robots.txt URL
	response_robot=$(curl -s -I -L -w "%{response_code}" -o /dev/null "$robot_URL")

	# Check the response code of the robots.txt HTTP request
	ok_robot=$(echo $response_robot | grep ^2)
	if [ -n "$ok_robot" ]
	then
		robots_path="./robots-txt/cat/robotstxt/$lineno.txt"
		blocklist_path="./robots-txt/cat/blocklist/$lineno.txt"
		curl -s "$robot_URL" > "$robots_path"

		# Use sed to find lines between "User-agent: *" and the next "User-agent:" block or the end of the file
		# Then keep each Disallow block and save to a blocklist file
		# https://unix.stackexchange.com/questions/264962/print-lines-of-a-file-between-two-matching-patterns
		cat "$robots_path" | sed -n '/^User-agent: \*$/,/^User-agent:.*$/p' | sed -n 's/^Disallow: \(.\+\)$/\1/p' > "$blocklist_path"

		# Check if the URL we want to crawl is disallowed using "grep -f" to provide the list of patterns from the blocklist
		disallowed=$(echo "$line" | grep -f "$blocklist_path")
		if [ -n "$disallowed" ]
		then
			echo "The URL $line is disallowed by $robot_URL"
			echo -e "$lineno\t$line\tdisallowed\t\t\t" >> "$tsv"
			continue
		fi
	fi

	###
	# Target URL
	###

    # curl: make an http request
	# -s --silent (do not display extra metadata)
	# -I --head (metadata only)
	# -L --location (follow redirections)
	# -w --write-out "format string" (add metadata at the end of the standard output)
	# -o output
	# tail -n 1 (keep only the last line)
	# $metadata is the HTTP response's status code and contains, separated by a tabulation, the content type
	metadata=$(curl -s -I -L -w "%{response_code}\t%{content_type}" -o /dev/null $line)
	
	# Keep only the first part of the variable, tab being the default separator
	# $(...) -> mandatory to store the result of the command into the variable
	response_code=$(echo "$metadata" | cut -f1)
	
	# Keep the part after the tabulation and look for an expression with "charset",
	# and divide it in two parts in the "=" sign and keep only the right part ("UTF-8")
	charset=$(echo "$metadata" | cut -f2 | grep -E -o "charset=.*" | cut -d= -f2)


	# ok if the http response code starts with 2 (200, 201,...)
	ok=$(echo $response_code | grep ^2)

	if [ -n "$ok" ]
	then
		# aspiration gets the whole html page without further processing
		aspiration_path="./aspirations/cat_aspirations/$lineno.html"
		dump_path="./dumps-text/cat_dumps/$lineno.txt"

		curl -s "$line" > "$aspiration_path"

		# lynx: browse a web page
		# -dump (disable interactive mode)
		# -nolist (remove links)
		# wc -w (count the number of words)
		# wc -l (count the number of occurences)
		lynx -dump -nolist $line > $dump_path
		num_words=$(cat "$dump_path" | wc -w)
		num_occurences=$(cat "$dump_path" | grep -i -o -E "(xarxa|xarxes)" | wc -l)
	else
		num_words=0
	fi

	echo -e "$lineno\t$line\t$response_code\t$charset\t$num_words\t$num_occurences" >> "$tsv"
done < $URL
