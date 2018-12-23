#!/bin/bash
export DEBIAN_FRONTEND=noninteractive;
apt-get update;
apt-get -q -y install rsync;

NDIR= `head -n 1 $1`;
#Comprueba que se ha accedido al directorio, sino salimos con error
    cd "$NDIR" > /dev/null 2>&1;
    
    if [[ $? != 0 ]]; then 
    echo "Error, directorio $NDIR no existe"
    exit 1;
    fi

    if [[ `ls nuevo3 | wc -l` != 0 ]]; then
    echo "Error, el directorio que está tratando de utilizar como backup está lleno"
    exit 1;
    else
    exit 0; 
    fi