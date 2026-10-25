#!/usr/bin/env bash

#para los colores
blueC="\e[0;34m\033[1m"
redC="\e[0;31m\033[1m"
purpleC="\e[0;35m\033[1m"
greenC="\e[0;32m\033[1m"
endC="\033[0m\e[0m"

#el nombre del directorio
direct="info"

# para la funcion de salir
function ctrl_c() {
  echo -e "\n\n[!] saliendo...\n"
  exit 1
}

trap ctrl_c INT

#crea el directorio para guardar los archivos.txt
mkdir -p $direct

# iniciando reconocimiento
echo "============================================="
echo -e "${redC} [+] INICIANDO RECONOCIMIENTO ${endC} [$(date '+%H:%M:%S')]"
echo "============================================="

#quien somos
echo -e "\n${blueC} QUIEN SOMOS: ${endC} $(whoami)"

# grupo al que pertenecemos info/grupos_pertenecemos.txt
echo -e "\n${blueC} GRUPOS A LOS QUE PERTENECEMOS: ${endC}"
id | tree $direct/grupos_pertenecemos.txt

# que permisos tenemos info/permisos.txt
echo -e "\n${blueC} QUE PRIVILEGIOS TENEMOS: ${endC}"
sudo -l 2>/dev/null | tree $direct/permisos.txt

#para las capabilities, se guarda en info/capabilities.txt
echo -e "\n${purpleC} == BUSQUEDA DE CAPABILITIES == ${endC}\n"
getcap -r / 2>/dev/null | tee $direct/capabilities.txt

# usuarios existentes, se guarda en info/users.txt
echo -e "\n${purpleC} == USUARIOS DEL SISTEMA == ${endC}\n"
grep -v "nologin" /etc/passwd | awk '{print $1}' FS=":" | tee $direct/users.txt

# para buscar archivos suid, se guarda en info/user.txt
echo -e "\n${purpleC} == ARCHIVOS SUID == ${endC}\n"
find / -perm -4000 -type f -ls 2>/dev/null | tee $direct/perms.txt

# Listando conexiones establecidas, se guarda en info/connections.txt
echo -e "\n${greenC}[++] CONEXIONES ESTABLECIDAS EN EL SISTEMA [++]:${endC}\n"
ss -nt | awk 'NR>1 {print $4}' | tee $direct/connections.txt

# Listando puertos abiertos en el sistema, se guarda en info/ports.txt
echo -e "\n${greenC}[++] Listando puertos abiertos en el sistema [++]:${endC}\n"
ss -nltp | awk 'NR>1 {print $4}' | tee $direct/ports.txt

echo -e "\n============================================="
echo -e "${redC} [+] RESUMEN ${endC}"
echo -e "=============================================\n"

for directory in "$direct"/*; do
  echo "Archivo con nombre $(basename $directory): $(wc -l <$directory) lineas"
done
