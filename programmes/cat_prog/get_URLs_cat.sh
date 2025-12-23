#!/bin/bash

# ./miniprojet-3.sh ../urls/fr.txt > ../tableaux/tableau-fr.html

# $# number of arguments passed to the program
#if [ $# -ne 1 ]
#then
#	echo "ce programme demande un argument"
#	exit 1
#fi

# $1 first argument passed to the program
URL=${1-URL/URL_cat.txt}
tsv="./tableaux/cat_tableaux/URLs.tsv"
rm -f "$tsv"

mkdir -p ./aspirations/cat_aspirations
rm -rf ./aspirations/cat_aspirations/*

mkdir -p ./dumps-text/cat_dumps
rm -rf ./dumps-text/cat_dumps/*

mkdir -p ./robots-txt/cat
rm -rf ./robots-cat/cat/*

# counter for the line number of the urls file
lineno=0
while read -r line;
do
	# display each line in the stderr
	echo "Fetching $line" 1>&2

	# increment the line counter by 1	
	lineno=$(expr $lineno + 1)

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

	# Adds "robots.txt" after each URL's root
	robot_URL=$(echo "$line" | sed -n 's/^\(https\?:\/\/[^\/]*\/\).*$/\1robots.txt/p')
	response_robot=$(curl -s -I -L -w "%{response_code}" -o /dev/null "$robot_URL")
	ok_robot=$(echo $response_robot | grep ^2)
	
	if [ -n "$ok_robot" ]
	then
		robots_path="./robots-txt/cat/$lineno.txt"
		curl -s "$robot_URL" > "$robots_path"
	fi

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
