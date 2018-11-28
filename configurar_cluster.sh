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