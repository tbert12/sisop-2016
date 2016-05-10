#!/bin/bash

RED='\033[0;31m' # Rojo
NC='\033[0m' # Sin color

cd 'binarios' > /dev/null

if [ $(($AMBIENTE_INICIALIZADO)) -ne 1 ]
  then
	GRUPO="$(dirname $PWD)"
	GRUPO="$GRUPO/"
	RESGDIR="$GRUPO""source/"
	###
	#echo "DS: $DirScript"
	#echo "GR: $GRUPO"
	#echo "RD: $RESGDIR"
	###
fi

if [ ! -e "$RESGDIR" ]
  then
	echo "No se encontró la carpeta de archivos de resguardo."
	echo "Esto puede deberse a que fue movida o eliminada, o que el ambiente no fue inicializado, o que simplemente no se detectó ninguna instalación."
	echo
	echo "Por seguridad, esta desinstalación se abortará automáticamente."
	echo "Para forzar una desinstalación, simplemente elimina el directorio $GRUPO"
	return 1
fi


echo
printf "DESINSTALADOR ~ ${RED}Está usted TOTAL E IRREVOCABLEMENTE SEGURO de querer eliminar el sistema CIPAK_G5 con toda la carpeta $GRUPO, los registros, reportes, configuración y demases?${NC}\n"
echo
printf "Esta es su última oportunidad ... (y/n) ~ "
read respuesta

if [ "$respuesta" != "y" -a "$respuesta" != "yes" ]
  then
	echo "Cancelado"
	return 1
fi
echo
echo "Frenando procesos que puedan estar corriendo..."

# Aniquilo todos los procesos por las dudas
start-stop-daemon --stop --name "RecibirOfertas." &> /dev/null
start-stop-daemon --stop --name "ProcesarOfertas" &> /dev/null
start-stop-daemon --stop --name "GenerarSorteo.s" &> /dev/null
start-stop-daemon --stop --name "DeterminarGanad" &> /dev/null


echo "Recreando instalador..."

cd "$RESGDIR" > /dev/null

mv "./*" "$GRUPO.." 2> /dev/null
mv "./Readme.md" "$GRUPO.." 2> /dev/null
mv "./installer.sh" "$GRUPO.." 2> /dev/null
mv "./source.tar.gz" "$GRUPO.." 2> /dev/null

if [ "$(ls -A)" ]
  then
	echo "Este desinstalador no ha logrado mover todos los archivos fuente"
	echo "Por favor, mover manualmente los archivos de la carpeta $GRUPO""source/ a algún lugar seguro, por si quisiera instalar nuevamente el sistema"
	echo "Una vez hecho eso, vuelva a correr este desinstalador"

	return 1
fi

AMBIENTE_INICIALIZADO=0
export AMBIENTE_INICIALIZADO


echo "Desinstalando sistema CIPAK..."

cd "$GRUPO"..
rm -rf "$GRUPO"

echo
echo "¡Desinstalación completada!"
echo

return 0
