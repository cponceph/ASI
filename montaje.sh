#!/bin/bash

aux=1;
while read linea$aux
do
    aux=$(($aux+1));
done < $1

echo "Acediendo al punto de montaje $linea2";
cd "$linea2" > /dev/null 2>&1;

if [[ $? != 0 ]]; then #Comprueba que se ha accedido al directorio, sino se crea
    echo "Directorio no existe, se va a crear $linea2"
    mkdir -p "$linea2";

    if [[ $? != 0 ]]; then #Comprueba que se ha creado el directorio correctamente
        >&2 echo "Directorio no creado, prueba con un nombre válido"
        exit 1;
    fi
else
    echo "Directorio: $linea2, ha sido creado."
    echo "Se va a acceder a él."
    cd "$linea2";

fi
echo "pwd: $(pwd)"
echo "Montando $linea1 en $linea2"

mount "$linea1" "$linea2" -t auto
if [[ $? != 0 ]]; then # Comprueba que se ha podido montar el dispositivo correctamente.
    echo "Error de montado, el dispositivo no existe o no puede ser montado."
    >&2 exit 1;
fi
#Obtenemos el tipo del sistema de ficheros del dispositivo
tipo=`df -Th | grep $linea1 | awk '{printf $2}'`
echo "Se va a modificar el fichero /etc/fstab, para que se monte el disco cada vez que arranque el sistema."
echo "$linea1    $linea2      $tipo    defaults    0         0" >> /etc/fstab;

