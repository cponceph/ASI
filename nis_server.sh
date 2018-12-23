#!/bin/bash
#@name: nis_server
#@author: Carlos Ponce Lazaro
#@author: David
#@version: 1.0
#@desc: Configura un servidor de NIX en el host local de Linux

#Leemos el nombre de dominio
NDOMINIO= `head -n 1 $1`;

if [ $? -ne 0 ]; then 
    >&2 echo "Error leyendo el nombre de dominio, especifique el nombre en una linea"
    exit 1;
fi

apt-get install rpcbind;
#Comprobamos si se tiene instalado el paquete ypserv e instalamos en caso negativo
which ypserv > /dev/null 2>&1;
if [ $? != 0 ];
then
    echo "Paquete ypserv no instalado, se va a instalar";
    apt-get update;
    export DEBIAN_FRONTEND=noninteractive
    apt-get -q -y install nis > /dev/null 2>&1;

    if [ $? != 0 ];
    then
        >&2 echo "Error al instalar el paquete ypserv."
        exit1;
    fi

    echo "Paquete ypserv  instalado correctamente."

else echo "El paquete ypserv ya está instalado - omitiendo."
fi

#Anadimos el nombre de dominio a la configuracion
domainname "$NDOMINIO";

#Iniciamos servicios necesarios
service rpcbind start;
service ypserv start;

