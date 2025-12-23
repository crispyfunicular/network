# network / réseau
Étude diachronique de l’emploi du terme « réseau » ou « network » en espagnol, catalan et mandarin ...

## Sens retenus
1. Informatique et numérique : réseau de neuronnes, réseau informatique, réseau sans fil...  
2. Social et organisationnel : réseau social, réseau criminel...  
3. Transports et infrastructures : réseau fluvial, réseau ferroviaire, réseau routier, réseau de transports...  
Le but de ces catégories est d'assurer une certaines représentativité des termes récoltés (échantillonnage qualitatif avant échantillonage quantitatif). Nous sommes évidemments conscient-es que certaines expression peuvent être classées dans plusieurs catégories à la fois.  

## Structure du projet  
- "programmes" : dossier contenant l'ensemble des scripts pour les trois langues  
- "URL" : dossier contenant les listes d'URL correspondant aux sites Internet mentionnant notre mot cible dans les trois langues étudiées  
- "tableaux" : dossier contenant les tableaux aux formats tsv et html (colonnes : lineno, adresse html, response code, charset, word number, occurrences, page HTML brute, dump textuel, concordancier HTML, robots.txt, concordancier couleurs)  
- "aspirations" : dossier contenant la source des sites mentionnés plus haut (un fichier .html par URL)  
- "dumps-text" : dossier contenant le texte brut (sans les balises html) pour chaque site (un fichier .txt par URL)  
- "tokenisation" : dossier contenant les mots du texte brut, un mot par ligne et un fichier .txt par URL 
- "contexte" : dossier contenant pour chaque page aspirée les extraits du dump textuel où apparaît le mot cible, avec une fenêtre de contexte (deux lignes avant et après) autour de l’occurrence  
- "concordances" : dossier contenant les concordanciers générés, au format HTML, à partir des fichiers de contexte. Le mot cible est mis en évidence avec, de part et d’autre, son contexte gauche et droit  
- "bigrammes" : dossier contenant des paires de mots contigus, pour tous les mots de chaque page aspirée  
- "robots-txt" : dossier contenant la page robots/txt de chaque page aspirée, lorsqu'elle existe, au format .txt  
