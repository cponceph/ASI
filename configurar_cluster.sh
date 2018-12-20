#!/bin/bash
if test $# -ne 1; #Comprueba que se le pasa el parametro adecuado
then
    >&2 echo "Modo de empleo: configurar_cluster.sh fichero_configuracion"
    exit 1;
fi
Cont_Linea=0;
while read linea #Lee el fichero pasado como parametro linea a linea
do
    Cont_Linea=$(($Cont_Linea+1));
    if [[ "$linea" = "#"* || -z $linea ]]; then #Se salta las lineas en blanco y las que mepiecen por '#'
        true;
    else

        if [[ ($(echo $linea | wc -w) != 3 ) ]]; then
            >&2 echo "Linea $Cont_Linea no cumple el formato"
            exit 2
        fi
        echo $linea | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" > /dev/null;
        retorno=$?
        echo $linea | grep -E "*.conf$" > /dev/null;
        retorno2=$?

        if [[ $retorno != 0 || $retorno2 != 0 ]]; then
            >&2 echo "Linea $Cont_Linea no cumple el formato"
            exit 2
        fi

    fi

done < $1

#Hacemos los checks de sintaxis de los ficheros de perfil de servicio en el nodo de control 
#y ejecutamos los scripts de configuracion en remoto recogiendo resultados
while read linea
do

    #Saltamos las lineas en blanco y las que empiecen por '#'
    if [[ "$linea" = "#"* || -z $linea ]]; then 
        true;
    else

    HOST=`echo $linea | awk '{ printf $1 }'`;
    SERVICIO=`echo $linea | awk '{ printf $2 }'`;
    CONFILE=`echo $linea | awk '{ printf $3 }'`;

    #Comprobamos que el servicio existe
    case "$SERVICIO" in
    montaje);;
    raid);;
    lvm);;
    nis_server) ;;
    nis_client) ;;
    nfs_server) ;;
    nfs_client) ;;
    backup_server) ;;
    backup_client) ;;
    *)
        >&2 echo "El servicio $SERVICIO no es configurable, especifique un servicio existente";
        exit 3;
    ;;
    esac
    
    #Copiamos el fichero de configuracion al host
    scp "$CONFILE" practicas@"$HOST":/tmp;

    #Recogemos el resultado
    if [ $? -ne 0 ]; then 
    >&2 echo "Error copiando el fichero de configuracion del servicio $SERVICIO a $HOST\n";
    exit 4;
    fi

    #Ejecutamos en remoto
    ssh practicas@"$HOST" 'bash -s' < "$SERVICIO".sh /tmp/"$CONFILE";

    #Recogemos resultado
    if [ $? -ne 0 ]; then 
    >&2 echo "Error ejecutando el script de configuracion del servicio $SERVICIO remotamente en $HOST\n";
    exit 5;
    fi

    #Eliminamos el fichero de configuracion
    ssh practicas@"$HOST" rm -rf /tmp/"$CONFILE";

    #Recogemos resultado
    if [ $? -ne 0 ]; then 
    >&2 echo "Error eliminando el fichero de configuracion del servicio $SERVICIO remotamente en $HOST\n";
    exit 6;
    fi

    fi
    
    

done < $1