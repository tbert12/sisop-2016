# --- Valores de ambiente por default ----
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
RESGDIR="$GRUPO""source/"

LOGSIZE=500
SLEEPTIME=1
# ----------------------------------------

arch_comprimido="source.tar.gz"


seteoVariables() {
	echo "Seteo de variables globales"
	echo "Ingrese un nuevo valor (en caso de carpetas, solo el nombre de la misma) o solo ENTER para mantener el valor por defecto."
	echo

	printf "\$GRUPO (directorio base; el valor por default es $GRUPO): "
	read input
	if [ "$input" != "" ]; then GRUPO="$PWD""$input/"; fi

	dirSinBarra="${BINDIR%/*}"
	printf "\$BINDIR (default: ${dirSinBarra##*/}/): "
	read input
	if [ "$input" != "" ]; then BINDIR="$GRUPO""${input%/*}/"; fi

	dirSinBarra="${ARRIDIR%/*}"
	printf "\$ARRIDIR (default: ${dirSinBarra##*/}/): "
	read input
	if [ "$input" != "" ]; then ARRIDIR="$GRUPO""${input%/*}/"; fi

	dirSinBarra="${DATDIR%/*}"
	printf "\$DATDIR (default: ${dirSinBarra##*/}/): "
	read input
	if [ "$input" != "" ]; then DATDIR="$GRUPO""${input%/*}/"; fi

	dirSinBarra="${OKDIR%/*}"
	printf "\$OKDIR (default: ${dirSinBarra##*/}/): "
	read input
	if [ "$input" != "" ]; then OKDIR="$GRUPO""${input%/*}/"; fi

	dirSinBarra="${PROCDIR%/*}"
	printf "\$PROCDIR (default: ${dirSinBarra##*/}/): "
	read input
	if [ "$input" != "" ]; then PROCDIR="$GRUPO""${input%/*}/"; fi

	dirSinBarra="${INFODIR%/*}"
	printf "\$INFODIR (default: ${dirSinBarra##*/}/): "
	read input
	if [ "$input" != "" ]; then INFODIR="$GRUPO""${input%/*}/"; fi

	dirSinBarra="${LOGDIR%/*}"
	printf "\$LOGDIR (default: ${dirSinBarra##*/}/): "
	read input
	if [ "$input" != "" ]; then LOGDIR="$GRUPO""${input%/*}/"; fi

	dirSinBarra="${NOKDIR%/*}"
	printf "\$NOKDIR (default: ${dirSinBarra##*/}/): "
	read input
	if [ "$input" != "" ]; then NOKDIR="$GRUPO""${input%/*}/"; fi

	dirSinBarra="${RESGDIR%/*}"
	printf "\$RESGDIR (default: ${dirSinBarra##*/}/): "
	read input
	if [ "$input" != "" ]; then RESGDIR="$GRUPO""${input%/*}/"; fi

	echo

	printf "\$LOGSIZE (tamaño límite para cada log; 0 = sin límite; default: $LOGSIZE Kbytes): "
	read input
	if [ "$input" != "" -a "$input" -eq "$input" -a "$input" -ge 0 ] 2> /dev/null; then LOGSIZE="$input"; else echo "Mantengo default"; fi

	printf "\$SLEEPTIME (para el demonio; default: $SLEEPTIME segundos): "
	read input
	if [ "$input" != "" -a "$input" -eq "$input" -a "$input" -ge 0 ] 2> /dev/null; then SLEEPTIME="$input"; else echo "Mantengo default"; fi
}


generarArchConfiguracion(){
	ARCH_CNF="$CONFDIR""CIPAK.cnf"
	echo "Creando archivo de configuración en $ARCH_CNF..."
	fecha_y_hora=$(date "+%d/%m/%Y %H:%M:%S")

	echo "LOGDIR=$LOGDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "LOGSIZE=$LOGSIZE=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "GRUPO=$GRUPO=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "BINDIR=$BINDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "MAEDIR=$MAEDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "ARRIDIR=$ARRIDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "OKDIR=$OKDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "PROCDIR=$PROCDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "INFODIR=$INFODIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "RESGDIR=$RESGDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "NOKDIR=$NOKDIR=$USER=$fecha_y_hora" >> "$ARCH_CNF"
	echo "SLEEPTIME=$SLEEPTIME=$USER=$fecha_y_hora" >> "$ARCH_CNF"
}


organizarArchivos(){
	if [ ! -e "$arch_comprimido" ]
	  then
		echo "Hubo un error: se requiere el archivo source.tar.gz en la carpeta $PWD para poder continuar la instalación."
		exit 1
	fi

	tar -xzf source.tar.gz

	cp -ar source/ARRIDIR/ "$DATDIR"
	cp -ar source/MAEDIR/ "$DATDIR"
	#mv source/ARRIDIR/* "$ARRIDIR"  # Esta línea inserta los archivos novedades por default en $ARRIDIR
	mv source/MAEDIR/* "$MAEDIR"
	mv source/BINDIR/* "$BINDIR"

	mv "$arch_comprimido" "$RESGDIR"
	rm -rf "source/"

	cp Readme.md "$RESGDIR"
	mv Readme.md "$GRUPO"
}


# /////////////////////// MAIN /////////////////////////////////////

# Chequea instalacion previa
if [ -e "$ARCH_CNF" ]
  then
	echo "Ya existe una instalación previa. Para reinstalar, primero corra \'bash $BINDIR""uninstall.sh\' y limpie el directorio."
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
if [ "$1" = "-d" ]
  then
	seteoVariables
	echo
	echo "-------------------------------------------"
	echo
fi
echo "Instalando..."
echo

mkdir --parents "$BINDIR" "$MAEDIR" "$ARRIDIR" "$DATDIR" "$OKDIR" "$PROCDIR" "$INFODIR" "$LOGDIR" "$NOKDIR" "$CONFDIR" "$RESGDIR"

generarArchConfiguracion

organizarArchivos

echo
echo "¡Instalación completada exitosamente!"
echo

mv "installer.sh" "$RESGDIR"

cd "$BINDIR"

return 0
