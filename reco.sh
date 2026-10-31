#!/usr/bin/env bash

#para los colores FORMATO RGB/HEXADECIMAL
blueC="\e[38;2;81;175;239m\e[1m"
redC="\e[38;2;204;51;51m\e[1m"
purpleC="\e[38;2;198;120;221m\e[1m"
greenC="\e[38;2;51;204;102m\e[1m"
yellowC="\e[38;2;255;204;0m\e[1m"
endC="\e[0m"

#el nombre del directorio
direct="info"

#para ver cuanto tarda el script
SECONDS=0

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
id | tee $direct/grupos_pertenecemos.txt

# que permisos tenemos info/permisos.txt
echo -e "\n${blueC} QUE PRIVILEGIOS TENEMOS: ${endC}"
sudo -l 2>/dev/null | tee $direct/permisos.txt

#IDENTIFICAR EL SISTEMA
echo -e "\n${yellowC} EN QUE OS ESTAMOS: ${endC}"
cat /etc/os-release | tee $direct/os.txt

#que gestor de paquetes segun el sistema
if [ -f /etc/arch-release ]; then
  pkg_manager="pacman"
elif [ -f /etc/redhat-release ]; then
  pkg_manager="yum"

elif [ -f /etc/debian_version ]; then
  pkg_manager="apt"
else
  echo -e "\n${redC}NO IDENFICADO EL OS${endC}"
fi
echo -e "\n ${yellowC}GESTOR DE PAQUETES: ${endC} $pkg_manager"

#para las capabilities, se guarda en info/capabilities.txt
echo -e "\n${purpleC} == BUSQUEDA DE CAPABILITIES == ${endC}\n"
getcap -r / 2>/dev/null | tee $direct/capabilities.txt

# usuarios existentes, se guarda en info/users.txt
echo -e "\n${purpleC} == USUARIOS DEL SISTEMA == ${endC}\n"
grep -v "nologin" /etc/passwd | awk '{print $1}' FS=":" | tee $direct/users.txt

# para buscar archivos suid, se guarda en info/user.txt
echo -e "\n${purpleC} == ARCHIVOS SUID == ${endC}\n"
find / -perm -4000 -type f -ls 2>/dev/null | tee $direct/perms.txt

# ENUMERACION DEL DIRECTORIO SSH
echo -e "\n ${purpleC} == ENUMERACION DIRECTORIO SSH == ${endC}"
if [ -d "$HOME"/.ssh ]; then
  keys=$(find "$HOME"/.ssh -name "*.pub" -type f 2>/dev/null | wc -l)

  if [ $keys -gt 0 ]; then
    echo -e "\n numero de claves publicas $keys"
  else
    echo -e "\n ${redC}No se han encontrado claves publicas${endC}"
  fi

  if [ -f "$HOME"/.ssh/authorized_keys ]; then
    n=$(wc -l <$HOME/.ssh/authorized_keys)
    echo -e "[+] Se ha encontrado un archivo authorized_keys con $n entradas"
  else
    echo -e "${redC} No se ha encontrado ningun archivo authorized_keys ${endC}"
  fi

else
  echo -e "\n ${redC}El directorio${endC} $HOME/.ssh ${redC}No existe${endC}\n"
fi

# Listando conexiones establecidas, se guarda en info/connections.txt
echo -e "\n${greenC}[++] CONEXIONES ESTABLECIDAS EN EL SISTEMA [++]:${endC}\n"
ss -nt | awk 'NR>1 {print $4}' | tee $direct/connections.txt

# Listando puertos abiertos en el sistema, se guarda en info/ports.txt
echo -e "\n${greenC}[++] Listando puertos abiertos en el sistema [++]:${endC}\n"
ss -nltp | awk 'NR>1 {print $4}' | grep -v "\[" | tee $direct/ports.txt

echo -e "\n============================================="
echo -e "${redC} [+] RESUMEN ${endC}"
echo -e "=============================================\n"

for directory in "$direct"/*; do
  echo "Archivo con nombre $(basename $directory): $(wc -l <$directory) lineas"
done

echo -e "\n============================================="
echo -e "\n SEGUNDOS DEL SCRIPT ACTIVO:   $SECONDS"
