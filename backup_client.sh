#!/bin/bash


export DEBIAN_FRONTEND=noninteractive;
apt-get update;
apt-get -q -y install rsync;

while read linea$aux
do
  aux=$(($aux+1))
done < $1

ORIGEN="$linea1"
HOST="$linea2"
DESTINO="$linea3"
FREC="$linea4"

#Checks
#Check1 existe el directorio origen

cd "$ORIGEN" > /dev/null 2>&1;
    
if [[ $? != 0 ]]; then 
echo "Error, directorio "$ORIGEN" no existe en origen"
exit 1;
fi

#Check2 el destino es alcanzable
if [[ `ping -c1 -W1 $HOST > /dev/null` != 0 ]]; then
echo "Error de host inalcanzable, no se puede encontrar el host $HOST";
exit 1;
fi

#Check3 el directorio en destino existe
#Ejecutamos en remoto
ssh root@"$HOST" "cd $DESTINO";
if [[ $? != 0 ]]; then 
echo "Error, directorio $DESTINO no existe en $HOST";
exit 1;
fi

#Todo correcto

#Realizamos el primer backup completo
rsync -ab --delete  --suffix=_`date +%F`  "$ORIGEN" root@"$HOST":"$DESTINO";
if [[ $? != 0 ]]; then 
echo "Error, no posee permisos suficientes para modificar el fichero $DESTINO en $HOST";
exit 1;
fi


#Configuramos el crontab con la periodicidad indicada
#Obtenemos el crontab actual
crontab -l > micron;
#Añadimos la linea que queremos
echo "00 /$FREC * * 0-6 rsync -ab --delete  --suffix=_`date +%F`  $ORIGEN root@$HOST:$DESTINO" >> micron;
#Instalamos el nuevo fichero de crontab
crontab micron;
rm micron;