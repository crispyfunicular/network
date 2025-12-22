#!/bin/bash

# Ce fichier sert à télécharger, nettoyer et recuperer le contexte et
# formluler le tableau

FICHIER_URLS="../../URL/chinois_urls.txt"
TABLEAU_HTML="../../tableaux/tableaux_zh.html"
MOT="网络"


echo "En train de faire un tableau...Veuillez attendre"
echo -e "
<html>
<head>
    <meta charset="UTF-8">
    <title>Tableau des URLs</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bulma@1.0.2/css/versions/bulma-no-dark-mode.min.css">
</head>
<body>
<section class="section has-background-grey">
<div class="container has-background-white">

<div class="hero has-text-centered">
  <div class="hero-body">
    <h1 class="title">Network（网络wang luo）— URLs Collectées</h1>
  </div>
</div>

<nav class="tabs is-centered">
  <ul>
    <li><a href="../../index.html">Accueil</a></li>
    <li class="is-active"><a href="tableau-fr.html">Tableau</a></li>
  </ul>
</nav>

<div class="columns is-centered">
  <div class="column is-full">
    <div class="block">
      <h3 class="title is-4 has-background-info has-text-white has-text-weight-semibold">Tableau des URL</h3>
      <div class="table-container">
        <table class="table is-bordered is-hoverable is-striped is-fullwidth">
          <thead class="has-background-info has-text-white">
            <tr>
                <th>Numéro</th>
                <th>URL</th>
                <th>Code</th>
                <th>Encodage</th>
                <th>Nombre d'occurences</th>
                <th>Page HTML brut</th>
                <th>Dump_Texte</th>
                <th>Contextes</th>
                <th>Concordancier</th>
                <th>Bigrammes</th>
                <th>Robot.txt</th>
                <th>Concordance avec coloration</th>
            </tr>
          </thead>" > "$TABLEAU_HTML"




lineno=1
aspiration_dir="../../aspirations/zh_aspirations"
dump_dir="../../dumps-text/zh_dumps"
context_dir="../../contextes/zh"



while read -r URL;
do
    echo "traitement pour $lineno : $URL"

    # les chemins
	html_file="$aspiration_dir/$lineno.html"
    dump_file="$dump_dir/$lineno.txt"
    context_file="$context_dir/$lineno.txt"

    # obtenir http_code et encoding de chaque url
    data=$(curl -s -i -L -w "%{http_code}\n%{content_type}" -o./.data.tmp "$URL")
    http_code=$(echo "$data" | head -1)

    #si le http_code n'est pas 200, on laisse rien à droite dans cette ligne de url
    if [[ "$http_code" != "200" ]]; then
        echo "Erreur HTTP ($http_code), on ne traite pas ce URL"
        echo "        <tr>
            <td>$lineno</td>
            <td><a href=\"$URL\" target=\"_blank\">$URL</a></td>
            <td>$http_code</td>
            <td>-</td>
            <td class=\"red\">-</td>
            <td>-</td>
            <td>-</td>
            <td>-</td>
            <td>-</td>
            <td>-</td>
            <td>-</td>
            <td>-</td>
        </tr>" >> "$TABLEAU_HTML"
        lineno=$((lineno+1))
        continue
    fi

    # telecharger les urls dans les fichiers HTML (Aspiration)
    # utilisation de wget, et les sauvegarde sous noms de 1-html, 2-html...
    # -q: mode silence, -O: donner le nom du fichier
    wget -q -O "$html_file" "$URL"

    # verifier et traiter l'encodage (charset)
    encoding=$(echo "$data" | tail -1 | grep -Po "charset=\S+" | cut -d"=" -f2)
    if [[ "$encoding" == "" ]];
    then
      encoding=$(grep -iPo "^Content-Type:.*?charset=\K[\w-]+" ./.data.tmp)
      if [[ -z "$encoding" ]]; then
      #si y a pas de charset dans le header, on le cherchera apres header par <meta charset> 或 <meta http-equiv="Content-Type">
        encoding=$(grep -iPo '<meta[^>]+charset=["'\'']?\K[\w-]+' "$html_file" | head -1)
      fi
    fi


    # y a des html dont le charset est gb2312 ou gbk
    # donc, il faut le verifier et le convertir en utf-8 si necessaire.
    if [[ "$encoding" != "utf-8" && "$encoding" != "UTF-8" ]];  #attention, ici, &&
    then
          echo "conversion de l'encodage ($encoding -> UTF-8)..."

          # faire la conversion，sauvegarder en tmp, et recouvrir l'origine
          tmp="../../aspirations/zh_aspirations/$lineno-utf8.html"
          iconv -f "$encoding" -t "UTF-8//IGNORE" "$html_file" > "$tmp" 2>/dev/null

          if [ $? -eq 0 ]; then #si la conversion a bien marche
              mv "$tmp" "$html_file" #recouvert
          else
              echo "Échec de la conversion, on ne traite pas ce URL"
              echo "        <tr>
                <td>$lineno</td>
                <td><a href="$URL" target=\"_blank\">$URL</a></td>
                <td>$http_code</td>
                <td>$encoding</td>
                <td class=\"red\">-</td>
                <td><a href="../aspirations/zh_aspirations/$lineno.html">HTML</a></td>
                <td>-</td>
                <td>-</td>
                <td>-</td>
                <td>-</td>
                <td>-</td>
                <td>-</td>
            </tr>" >> "$TABLEAU_HTML"
              lineno=$((lineno+1))
              continue
          fi
      fi

    # extraire dump_texte
    # l'utilisation de lynx pour omttre les balises de HTML
    # -assume_charset=utf-8
    lynx -dump -nolist -assume_charset=utf-8 -display_charset=utf-8 "$html_file" > "$dump_file"

    # compter la frequence du mot  网络 dans ce html
    COMPTE=$(grep -o "$MOT" "$dump_file" | wc -l)

    # EXTRAIRE le contexte
    # -C 2    2 lignes au-dessus et au-dessous
    grep -C 2 "$MOT" "$dump_file" > "$context_file"

    # obtenir le fichier robot.txt dans la racine de ce URL comme http://news.sina.com.cn/abc/def ----> http://news.sina.com.cn
    base_url=$(echo "$URL" | cut -d'/' -f1-3)

    # le chemin sauvegardé vers le robot.txt
    robots_file="../../robottxt/zh/robot_$lineno.txt"

    # Essaie de telechargement juste 1 fois 10 secondes
    wget -q -T 10 -t 1 -O "$robots_file" "$base_url/robots.txt"

    #
    if [ -s "$robots_file" ]; then
      robots_cell="<a href=\"../robottxt/zh/robot_$lineno.txt\">robot.txt</a>"
    else
      robots_cell="Absence"
      rm "$robots_file" 2>/dev/null
    fi

    echo "        <tr>
      <td>$lineno</td>
      <td><a href=\"$URL\" target=\"_blank\">$URL</a></td>
      <td>$http_code</td>
      <td>$encoding</td>
      <td class=\"red\">$COMPTE</td>
      <td><a href=\"../aspirations/zh_aspirations/$lineno.html\">HTML</a></td>
      <td><a href=\"../dumps-text/zh_dumps/$lineno.txt\">Dump_Texte</a></td>
      <td><a href=\"../contextes/zh/$lineno.txt\">Contexte</a></td>
      <td><a href=\"../concordances/zh/$lineno-concord.html\">Concordance</a></td>
      <td><a href=\"../bigrammes/zh/${lineno}_bigramme.txt\">Bigramme</a></td>
      <td>$robots_cell</td>
      <td><a href=\"../concor_coloration/zh/${lineno}_color.html\">concodance_coloré</a></td>
      </tr>" >> "$TABLEAU_HTML"
      lineno=$((lineno+1))


done < "$FICHIER_URLS"

echo "    </table>
</body>
</html>" >> "$TABLEAU_HTML"

echo "C'est bon, voir le resultat dans $TABLEAU_HTML ."
