#!/bin/bash

export DEBIAN_FRONTEND=noninteractive;
apt-get update;
apt-get -q -y install nfs-kernel-server;



while read directorio$aux
do

    #Comprueba que se ha accedido al directorio, sino salimos con error
    cd "$directorio$aux" > /dev/null 2>&1;
    
    if [[ $? != 0 ]]; then 
    echo "Error, directorio $directorio$aux no existe"
    exit 1;
    fi

    #Añadimos la linea para exportar el directorio por todas las interfaces
    echo "$directorio$aux    *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports;
    if [[ $? != 0 ]]; then 
            echo "Ha habido algun problema al crear el export, puede deberse a un fallo de instalacion o de privilegios del fichero /etc/exports"
            exit 1;
    fi

    aux=$(($aux+1));

done < $1

#Permitimos la conectividad a través de portmap
echo "portmap:ALL" >> /etc/hosts.allow;

#Una vez generado el fichero de exports correctamente rearrancamos el servicio
service nfs-kernel-server restart;
if [[ $? != 0 ]]; then 
        echo "La sintaxis del fichero de exports es incorrecta"
        exit 2;
fi


