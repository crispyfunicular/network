#!/bin/bash

# ./miniprojet-3.sh ../urls/fr.txt > ../tableaux/tableau-fr.html

# $# number of arguments passed to the program
if [ $# -ne 1 ]
then
	echo "ce programme demande un argument"
	exit 1
fi

# $1 first argument passed to the program
URL=$1

# cat << EOF allows to print multiple lines at once
# Write the begining of the HTML file/table
cat << EOF
<!doctype html>
	<html>
		<head>
			<meta charset="UTF-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1" />
            <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css">
			<title>Mini-projet 2</title>
		</head>

		<body>
            <section class="section">
                <div class="container">
					<table class="table is-hoverable is-bordered is-striped">
						
						<thead class=""has-background-primary-35 has-text-primary-35-invert"">
							<tr>
								<th scope="col">line no</th>
								<th scope="col">adresse html</th>
								<th scope="col">response code</th>
								<th scope="col">charset</th>
								<th scope="col">word number</th>
								<th scope="col">occurrences</th>
								<th scope="col">page HTML brute</th>
								<th scope="col">dump textuel</th>
								<th scope="col">concordancier HTML</th>
								<th scope="col">robots.txt</th>
								<th scope="col">concordancier couleurs</th>
							</tr>
						</thead>

						<tbody>
EOF

# counter for the line number of the urls file
lineno=0
while read -r line;
do
	# increment the line counter by 1	
	lineno=$(expr $lineno + 1)

    # curl: make an http request
	# -s --silent (do not display extra metadata)
	# -I --head (metadata only)
	# -L --location (follow redirections)
	# -w --write-out "format string" (add metadata at the end of the standard output)
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
	

	if [ -n "$ok" ];
	then
		# lynx: browse a web page
		# -dump (disable interactive mode)
		# -nolist (remove links)
		# wc -w (count the number of words)
		num_words=$(lynx -dump -nolist $line | wc -w)
	else
		num_words=0
	fi
	

	# Write one table row (<tr>) for each line in fr.txt
	# When different than 200, the response code is red (class="has-text-danger")
	if ! [[ "$response_code" -eq 200 ]];
	then
		rc_class=' class="has-text-danger"'
		cat << EOF
						<tr>
							<td>$lineno</td>
							<td><a href="$line">$line</td>
							<td${rc_class}>$response_code</td>
							<td>$charset</td>
							<td>$num_words</td>
							<td>occurrences</td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
							<td></td>
						</tr>
EOF
	else
		rc_class=''
		cat << EOF
							<tr>
								<td>$lineno</td>
								<td><a href="$line">$line</td>
								<td${rc_class}>$response_code</td>
								<td>$charset</td>
								<td>$num_words</td>
								<td>occurrences</td>
								<td><a href="">page HTML brute</a></td>
								<td><a href="">dump textuel</a></td>
								<td><a href="">concordancier HTML</a></td>
								<td><a href="">robots.txt</a></td>
								<td><a href="">concordancier couleurs</a></td>
							</tr>
EOF
	fi

	cat << EOF
							<tr>
								<td>$lineno</td>
								<td><a href="$line">$line</td>
								<td${rc_class}>$response_code</td>
								<td>$charset</td>
								<td>$num_words</td>
								<td>occurrences</td>
								<td><a href="">page HTML brute</a></td>
								<td><a href="">dump textuel</a></td>
								<td><a href="">concordancier HTML</a></td>
								<td><a href="">robots.txt</a></td>
								<td><a href="">concordancier couleurs</a></td>
							</tr>
EOF

done < $URL

# Write the end of the HTML table/file
cat << EOF
						</tbody>
					</table>
                </div>
            </section>
        </body>
    </html>
EOF