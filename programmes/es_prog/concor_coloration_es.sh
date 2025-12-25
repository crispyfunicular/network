#!/bin/bash

DIR_ORIGEN="../../concordances/es"
DIR_DESTINO="../../concor_coloration/es"

ESTILO="color: red; font-weight: bold;"

PALABRAS="telecomunicaciones|infraestructura|monofilamento|funcionamiento|mantenimiento|comunicaciones|instalaciones|horizontales|ferroviaria|localización|electricidad|preferencias|computadoras|herramientas|operaciones|principales|carreteras|deportivas|transporte|estructura|seguridad|marketing|camuflaje|capacidad|objetivos|productos|accesorios|permiten|sociales|agencias|network|agencia|recibir|mejorar|comprar|anuncios|peligros|mallas|utiliza|sistema|altura|metros|tieme|puede|pesca|hilos|tipos|futbol|social|acceso|tenis|malla|cable|acero|vial|plan|cada|gran|esta|solo|tipo|hilo|mono|capa|ser|uso|lan|seo|ley|ads|png|han"


if [ ! -d "$DIR_DESTINO" ]; then
    echo "Creando carpeta de destino: $DIR_DESTINO"
    mkdir -p "$DIR_DESTINO"
fi

echo "Procesando archivos desde: $DIR_ORIGEN"

contador=0

for archivo in "$DIR_ORIGEN"/espagnol*.html; do
    [ -e "$archivo" ] || continue

    nombre_base=$(basename "$archivo")
    archivo_salida="$DIR_DESTINO/$nombre_base"
     
    perl -CSD -pe "s/(<[^>]+>)|(\b(?:$PALABRAS)\b)/\$1 ? \$1 : \"<span style='$ESTILO'>\$2<\/span>\"/gie" "$archivo" > "$archivo_salida"
    
    ((contador++))
done

echo "--------------------------------------------------"
echo "¡LISTO!"
echo "Se han procesado $contador archivos."
echo "Los archivos coloreados están en: $DIR_DESTINO"