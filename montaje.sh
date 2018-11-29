if test $# -ne 2; #Comprueba que se le pasa el parametro adecuado
then
    >&2 echo "Modo de empleo: configurar_cluster.sh [Opciones] fichero_configuracion"
    exit 1;
elif [[ $1 = "mount" ]]; then

    aux=1;
    while read linea$aux
    do
        aux=$(($aux+1));
    done < $2

    echo "Acediendo al punto de montaje $linea2";
    cd "$linea2" > /dev/null 2>&1;

    if [[ $? != 0 ]]; then #Comprueba que se ha accedido al directorio, sino se crea
    echo "Directorio no existe, se va a crear $linea2"
    mkdir -p "$linea2";

    if [[ $? != 0 ]]; then #Comprueba que se ha creado el directorio correctamente
    echo "Directorio no creado, prueba con un nombre válido"
    exit 1;
else
    echo "Directorio: $linea2, ha sido creado."
    echo "Se va a acceder a él."
    cd "$linea2";
fi
fi
echo "pwd: $(pwd)"
echo "Montando $linea1 en $linea2"
mount "$linea1" "$linea2"
echo "$liena1    $linea2      ext4    auto    0         0" >> /etc/fstab

fi