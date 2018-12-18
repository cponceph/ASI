#!/bin/bash
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


#Bucle de lectura del fichero de configuración del LVM
aux=1
mem_total=0 #Suma total del espacio requerido por los volúmenes
while read linea$aux #Lee las tres lineas del servcio
do
    aux=$(($aux+1));
done < $2

if [ $aux -lt 3 ] #Comprueba que el fichero leido está compuesto de al menos 3 líneas.
then
    echo "Fichero con formato incorrecto, asgurese de pasar el número de argumentos adecuados."
    exit 1;
fi

iterador=1;
while read lin
do
    if [ $iterador -ge 3 ]
    then
	aux=$(echo $lin | cut -d " " -f 2 | cut -d "G" -f1);
	mem_total=$(($mem_total+$aux));
    fi
    iterador=$(($iterador+1));
done < $2

echo "El espacio requerido en total es: $mem_total"

fi
