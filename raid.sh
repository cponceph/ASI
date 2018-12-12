if test $# -ne 2; #Comprueba que se le pasa el parametro adecuado
then
    >&2 echo "Modo de empleo: configurar_cluster.sh [Opciones] fichero_configuracion"
    exit 1;

elif [[ $1 = "raid" ]]; then #Comprueba que sea el servicio raid
    aux=1;
    while read linea$aux #Lee las tres lineas del servcio
    do
        aux=$(($aux+1));
    done < $2
fi

echo "Instalando el programa mdadm"
apt-get install -y mdadm > /dev/null 2>&1  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! La instalación despliega un menú de confirmación, hay que evitarlo

if [[ $? != 0 ]]; then
    echo "Error durante la instalación de mdadm"
    exit 1;
fi

echo "mdamd ha sido instalado satisfactoriamente."
echo "Montando raid especificado en el fichero $2"

mdadm --create "$linea1" --level="$linea2" --raid-devices=$(echo $linea3 | wc -w)  "$linea3" > /dev/null 2>&1; #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Tambíen pide confirmación con yes, hay que evitarlos

if [[ $? != 0 ]]; then
    echo "Error al crear el raid, asegurese de estar pasando los directorios adecuados."
    exit 1;
fi

echo "Raid configurado correctamente."
