#!/bin/bash

export DEBIAN_FRONTEND=noninteractive;
apt-get update;
apt-get -q -y install nfs-common;


while read servicio$aux
do 
    
    if [[ `echo "$directorio$aux" | awk -F ' ' '{print NF; exit}'` -eq 3 ]];
    echo "Error por falta de parámetros de configuración";
    exit 1;
    fi
    
    HOST=`echo $servicio$aux | awk '{ printf $1 }'`;
    DIR=`echo $servicio$aux | awk '{ printf $2 }'`;
    MOUNTPOINT=`echo $servicio$aux | awk '{ printf $3 }'`;

    if [[ `ping -c1 -W1 $HOST > /dev/null` != 0 ]]; then
    echo "Error de host inalcanzable, no se puede encontrar el host $HOST";
    exit 1;
    fi

    cd "$DIR" > /dev/null 2>&1;
    if [[ $? != 0 ]]; then #Comprueba que se ha accedido al directorio, sino se crea
    echo "Directorio no existe, se va a crear $DIR"
    mkdir -p "$DIR";
    

        if [[ $? != 0 ]]; then #Comprueba que se ha creado el directorio correctamente
            echo "Directorio no creado, prueba con un nombre válido"
            exit 2;
        fi
    else
    echo "Directorio: $DIR, ha sido creado."
    fi

    mount "$HOST:$DIR $MOUNTPOINT";
    if [[ $? != 0 ]]; then 
            echo "El directorio no ha podido ser montado, asegúrese de que el servicio NFS exporta correctamente en $HOST"
            exit 1;
    fi
    tipo=`df -Th | grep $HOST:$DIR | awk '{printf $2}'`
    echo "$DIR    $MOUNTPOINT      $tipo    defaults    0         0" >> /etc/fstab;

    if [[ $? != 0 ]]; then 
            echo "Error montando el directorio $DIR en $MOUNTPOINT"
            exit 1;
    fi

    aux=$(($aux+1));
done < $1

