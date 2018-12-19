#!/bin/bash
if test $# -ne 2; #Comprueba que se le pasa el parametro adecuado
then
    >&2 echo "Modo de empleo: configurar_cluster.sh [Opciones] fichero_configuracion"
    exit 1;

elif [[ $1 = "lvm" ]]; then #Comprueba que sea el servicio lvm
aux=1;
while read linea$aux #Lee las lineas del servcio
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
        >&2 echo "Error al instalar el paquete lvm2."
        exit1;
    fi

    echo "Paquete lvm2, instalado correctamente."

else echo "El paquete ya está instalado."

fi


#Bucle de lectura del fichero de configuración del LVM
aux=1
mem_total=0 #Suma total del espacio requerido por los volúmenes
mem_disponible=0; #Suma de la memoria disponible en las particiones de el/los discos
while read linea$aux #Lee las tres lineas del servcio
do
    aux=$(($aux+1));
done < $2

if [ $aux -lt 3 ] #Comprueba que el fichero leido está compuesto de al menos 3 líneas.
then
    >&2 echo "Fichero con formato incorrecto, asgurese de pasar el número de argumentos adecuados."
    exit 1;
fi

iterador=1;
while read lin # Este bucle lee el fichero pasado como parametro para calcular la memoria requerida para configurar el fichero, según los criterios del mismo
do
    if [ $iterador -ge 3 ] # Pasa por alto las dos primeras lineas.
    then
        aux=$(echo $lin | cut -d " " -f 2 | cut -d "G" -f1); # Extrae los números que indican la memoria requerida
        mem_total=$(($mem_total+$aux));
    fi
    iterador=$(($iterador+1));
done < $2

echo "El espacio requerido en total es $mem_total GB"

echo "Ahora se va a sumar el espacio disponible."
it=$(echo $linea2 | wc -w);

while [ $it != 0 ] # Recorre las palabras (directorios) expresado en la segunda linea del fichero pasado como parámetro para sumar el espacio del que disponen las particiones
do
    aux=$(echo $linea2 | cut -d " " -f $it); # Obtiene el directorio del disco
    tam=$(lsblk -o SIZE $aux | cut -d "G" -f 1 | sed -n 2p);
    mem_disponible=$(($mem_disponible+$tam));
    it=$(($it-1));
done


if [ $mem_disponible -lt $mem_total ] #Comprueba que el espacio requerido y el existente concuerden
then
    echo "La memoria disponible en los discos es de un total de $mem_disponible Gb
    Y la que solicita el fichero es $mem_total Gb"
    exit 1;
fi

echo "El espacio disponible es de un total de $mem_disponible GB"

it=$(echo $linea2 | wc -w);

while [ $it != 0 ] # Recorre las palabras (directorios) expresado en la segunda linea del fichero pasado como parámetro para borrar las particiones de disco si existen y crea los correspondientes volúmenes físcicos
do
    aux=$(echo $linea2 | cut -d " " -f $it); # Obtiene el directorio del disco
    echo "A continuación se borran las particiones de disco para $aux"
    dd if=/dev/zero of=$aux bs=1k count=1 > /dev/null 2>&1;
    echo "Creando volumen físico para $aux"
    pvcreate $aux > /dev/null 2>&1;
    it=$(($it-1));
done

echo "Todas las particiones han sido borradas y los volumenes fisicos creados."
echo "Construyendo volumen físico $linea1"
vgcreate $linea1 $linea2 > /dev/null 2>&1;

aux=$(echo $2 | wc -l);
#Este bucle recorre las lineas del fichero que continen la configuración de los LV
while read lin #Lee las lineas del servcio
do
    if [ $aux -gt 2 ]
    then
        nombre=$(echo $lin | cut -d " " -f 1);
        tam=$(echo $lin | cut -d " " -f 2 | cut -d "B" -f1);
        echo "Se va a crear el volumen lógico $nombre."
        lvcreate -L $tam -n $nombre $linea1 > /dev/null 2>&1;
    fi
    aux=$(($aux+1));
done < $2

fi
