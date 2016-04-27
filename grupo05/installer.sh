###
GRUPO=$(pwd)"/Grupo05/"

BINDIR="$GRUPO""binarios/"
MAEDIR="$GRUPO""maestros/"
ARRIDIR="$GRUPO""arribados/"
DATDIR="$GRUPO""datos/"
OKDIR="$GRUPO""aceptados/"
PROCDIR="$GRUPO""procesados/"
INFODIR="$GRUPO""informes/"
LOGDIR="$GRUPO""bitacoras/"
NOKDIR="$GRUPO""rechazados/"
CONFDIR="$GRUPO""config/"

LOGSIZE=50000
SLEEPTIME=10
###

arch_comprimido="source.tar.gz"


seteoVariables() {
	echo "Seteo de variables globales"
	echo "Ingrese un nuevo valor (en caso de carpetas, solo el nombre de la misma) o solo ENTER para mantener el valor por defecto."
	echo

	printf "\$GRUPO (default $GRUPO): "
	read input
	if [ "$input" != "" ]; then GRUPO="$PWD""$input/"; fi

	printf "\$BINDIR (default $BINDIR): "
	read input
	if [ "$input" != "" ]; then BINDIR="$GRUPO""$input/"; fi

	printf "\$ARRIDIR (default $ARRIDIR): "
	read input
	if [ "$input" != "" ]; then ARRIDIR="$GRUPO""$input/"; fi

	printf "\$DATDIR (default $DATDIR): "
	read input
	if [ "$input" != "" ]; then DATDIR="$GRUPO""$input/"; fi

	printf "\$OKDIR (default $OKDIR): "
	read input
	if [ "$input" != "" ]; then OKDIR="$GRUPO""$input/"; fi

	printf "\$PROCDIR (default $PROCDIR): "
	read input
	if [ "$input" != "" ]; then PROCDIR="$GRUPO""$input/"; fi

	printf "\$INFODIR (default $INFODIR): "
	read input
	if [ "$input" != "" ]; then INFODIR="$GRUPO""$input/"; fi

	printf "\$LOGDIR (default $LOGDIR): "
	read input
	if [ "$input" != "" ]; then LOGDIR="$GRUPO""$input/"; fi

	printf "\$NOKDIR (default $NOKDIR): "
	read input
	if [ "$input" != "" ]; then NOKDIR="$GRUPO""$input/"; fi

	printf "\$CONFDIR (default $CONFDIR): "
	read input
	if [ "$input" != "" ]; then CONFDIR="$GRUPO""$input/"; fi

	echo

	printf "\$LOGSIZE (default $LOGSIZE bytes): "
	read input
	if [ "$input" != "" -a "$input" -eq "$input" -a "$input" -gt 0 ] 2> /dev/null; then LOGSIZE="$input"; else echo "Mantengo default"; fi

	printf "\$SLEEPTIME (default $SLEEPTIME segundos): "
	read input
	if [ "$input" != "" -a "$input" -eq "$input" -a "$input" -ge 0 ] 2> /dev/null; then SLEEPTIME="$input"; else echo "Mantengo default"; fi
}

generarArchConfiguracion(){
	ARCH_CNF="$CONFDIR""CIPAK.cnf"
	echo "Creando archivo de configuración en $ARCH_CNF..."
	fecha_y_hora=$(date "+%d/%m/%Y %H:%M:%S")

	echo "GRUPO=$GRUPO=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "BINDIR=$BINDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "MAEDIR=$MAEDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "ARRIDIR=$ARRIDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "OKDIR=$OKDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "PROCDIR=$PROCDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "INFODIR=$INFODIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "LOGDIR=$LOGDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "NOKDIR=$NOKDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "CONFDIR=$CONFDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"  # ignorado en el enunciado
	echo "LOGSIZE=$LOGSIZE=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "SLEEPTIME=$SLEEPTIME=$USER=$fecha_y_hora" >> "$ARCH_CNF"
}

organizarArchivos(){
	if [ ! -e "$arch_comprimido" ]
	  then
		echo "Hubo un error: se requiere el archivo source.tar.gz en la carpeta $PWD para poder continuar la instalación."
		exit 1
	fi

	tar -xvzf source.tar.gz > /dev/null # Ignorar output

	### de alguna forma usar MoverArchivo.sh ?
	mv source/ARRIDIR/* "$ARRIDIR"
	mv source/MAEDIR/* "$MAEDIR"
	mv source/BINDIR/* "$BINDIR"

	mv "$arch_comprimido" "$GRUPO""source/"
	rm -rf "source/"
}


# /////////////////////// MAIN /////////////////////////////////////

# Chequea instalacion previa
if [ -e "$ARCH_CNF" ]
  then
	echo "Ya existe una instalacion previa. Para reinstalar, primero desinstale y limpia el directorio."
	return 1
fi


if [ ! -e "$arch_comprimido" ]
  then
	echo "Hubo un error: se requiere el archivo source.tar.gz en la carpeta actual ($PWD) para poder efectuar la instalación."
	exit 1
fi


echo
echo "~ Inicio de instalación del sistema CIPAK ~"
echo "-------------------------------------------"
echo
seteoVariables
echo
echo "-------------------------------------------"
echo
echo "Instalando..."
echo

mkdir --parents "$BINDIR" "$MAEDIR" "$ARRIDIR" "$DATDIR" "$OKDIR" "$PROCDIR" "$INFODIR" "$LOGDIR" "$NOKDIR" "$CONFDIR" "$GRUPO""source/"

generarArchConfiguracion

organizarArchivos

echo
echo "¡Instalación completada exitosamente!"
echo

mv "$0" "$GRUPO""source/"

exit 0
