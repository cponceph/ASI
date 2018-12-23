#!/bin/bash

aux=1;
while read linea$aux #Lee las tres lineas del servcio
do
    aux=$(($aux+1));
done < $1

echo "Instalando el programa mdadm"
export  DEBIAN_FRONTEND=noninteractive;  # Esto bloquea toda la interacción con el ususario durante la instalación
apt-get install -y mdadm #> /dev/null 2>&1  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! La instalación despliega un menú de confirmación, hay que evitarlo

if [[ $? != 0 ]]; then
    >&2 echo "Error durante la instalación de mdadm"
    exit 1;
fi

echo "mdamd ha sido instalado satisfactoriamente."
echo "Montando raid especificado en el fichero $1"

#Comprobamos que el servicio existe
case "$SERVICIO" in
0);;
1);;
4);;
5) ;;
6) ;;
10) ;;
*)
    >&2 echo "Error nivel de RAID inválido.";
    exit 1;
;;
esac

mdadm --create "$linea1" --metadata=0.90 --level="$linea2" --raid-devices=$(echo $linea3 | wc -w)  $linea3 > /dev/null 2>&1; #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!Tambíen pide confirmación con yes, hay que evitarlos

if [[ $? != 0 ]]; then
    >&2 echo "Error al crear el raid, asegurese de estar pasando los directorios adecuados."
    exit 1;
fi

echo "Raid configurado correctamente."

echo "Se va a escribir la configuración del raid en mdadm.conf para que se pueda configurar cada vez que arranca el sistema"

mdadm --detail -scan >> /etc/mdadm/mdadm.conf;

echo "Se va a modificar el fichero /etc/rc.local sustituyendo la ultima linea por otra instrucción que active el raid en el boot del sistema."
# Hay que escribir la siguiente instrucción para que se ejecute durante el boot del sistema:
sed -i 's/exit 0/mdadm -As linea1 \n exit 0/g' /etc/rc.local > /dev/null 2>&1;
sed -i "s:linea1:$linea1:" /etc/rc.local > /dev/null 2>&1;
echo "Fichero modificado correctamente."
