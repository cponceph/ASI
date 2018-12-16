if test $# -ne 2; #Comprueba que se le pasa el parametro adecuado
then
    >&2 echo "Modo de empleo: configurar_cluster.sh [Opciones] fichero_configuracion"
    exit 1;

elif [[ $1 = "lvm" ]]; then #Comprueba que sea el servicio raid
aux=1;
while read linea$aux #Lee las tres lineas del servcio
do
    aux=$(($aux+1));
done < $2

echo "Antes de usar el comando lvm, se comprobará que está instalado."
which lvm > /dev/null 2>&1;

if [ $? != 0 ];
then
    echo "Paquete lvm2 no instalado, se va a instalar";

    apt-get install -y lvm2 > /dev/null 2>&1;

    if [ $? != 0 ];
    then
        echo "Error al instalar el paquete lvm2."
        exit1;
    fi

    echo "Paquete lvm2, instalado correctamente."

else echo "El paquete ya está instalado."

fi
fi
