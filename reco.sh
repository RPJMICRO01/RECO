#!/bin/bash

#para los colores
blueC="\e[0;34m\033[1m"
endC="\033[0m\e[0m"

# para la funcion de salir
function ctrl_c(){ echo -e "\n\n[!] saliendo...\n"; exit 1;}

trap ctrl_c INT

#quien somos
echo -e "${blueC} == QUIEN SOMOS == \n ${endC}"
whoami

echo -e "${blueC} == BUSQUEDA DE CAPABILITIES == \n ${endC}"
#para la revision de las capabilities
getcap -r / 2>/dev/null

# grupo al que pertenecemos
echo -e "\n${blueC} == GRUPOS A LOS QUE PERTENECEMOS == \n ${endC}"
id

# usuarios existentes
echo -e "\n${blueC} == USUARIOS DEL SISTEMA == \n ${endC}"
cat /etc/passwd

# que permisos tenemos
echo -e "\n${blueC} == QUE PRIVILEGIOS TENEMOS == \n ${endC}"
sudo -l 2>/dev/null

# para buscar archivos suid
echo -e "\n${blueC} == ARCHIVOS SUID == \n ${endC}"
find -perm -4000 -ls 2>/dev/null
