#!/usr/bin/env bash

DOSSIER_SOURCE="../../concordances/es"
DOSSIER_CIBLE="../../concor_coloration/es"

STYLE_MOT="color: red; font-weight: bold;"

MOTS="telecomunicaciones|infraestructura|monofilamento|funcionamiento|mantenimiento|comunicaciones|instalaciones|horizontales|ferroviaria|localización|electricidad|preferencias|computadoras|herramientas|operaciones|principales|carreteras|deportivas|transporte|estructura|seguridad|marketing|camuflaje|capacidad|objetivos|productos|accesorios|permiten|sociales|agencias|network|agencia|recibir|mejorar|comprar|anuncios|peligros|mallas|utiliza|sistema|altura|metros|tieme|puede|pesca|hilos|tipos|futbol|social|acceso|tenis|malla|cable|acero|vial|plan|cada|gran|esta|solo|tipo|hilo|mono|capa|ser|uso|lan|seo|ley|ads|png|han"

if [ ! -d "$DOSSIER_CIBLE" ]; then
    echo "Création du dossier cible : $DOSSIER_CIBLE"
    mkdir -p "$DOSSIER_CIBLE"
fi

echo "Traitement des fichiers depuis : $DOSSIER_SOURCE"

compteur=0

for fichier in "$DOSSIER_SOURCE"/espagnol*.html; do
    [ -e "$fichier" ] || continue

    nom_base=$(basename "$fichier")
    fichier_sortie="$DOSSIER_CIBLE/$nom_base"
     
    perl -CSD -pe "s/(<[^>]+>)|(\b(?:$MOTS)\b)/\$1 ? \$1 : \"<span style='$STYLE_MOT'>\$2<\/span>\"/gie" "$fichier" > "$fichier_sortie"
    
    ((compteur++))
done

echo "--------------------------------------------------"
echo "TERMINÉ !"
echo "Nombre de fichiers traités : $compteur"
echo "Les fichiers colorés se trouvent dans : $DOSSIER_CIBLE"