logMessage () {
	COMANDO=$1
	MSG=$2
	MSG_TYPE=$3

	if [ -z "$COMANDO" ]; then
		echo "$MSG"
	else
		bash GrabarBitacora.sh "$COMANDO" "$MSG" "$MSG_TYPE"
	fi
}

getProxNroSecuencia () {
	AUX_FILE="$DESTINO$DPLDIR""secuencia.aux"
	if [ -f "$AUX_FILE" ]; then
		NRO=`head -n 1 "$AUX_FILE"`
		PROX_NRO="$(($NRO + 1))"
		echo "$PROX_NRO" > "$AUX_FILE"
	else
		PROX_NRO=1
		echo "$PROX_NRO" > "$AUX_FILE"
	fi
	return "$PROX_NRO"
}

ORIGEN=$1
DESTINO=$2
COMANDO=$3

DPLDIR="dpl/"

ORIGEN_PATH=`echo ${ORIGEN%/*}`
DESTINO_PATH=`echo ${DESTINO%/*}`
if [[ "$ORIGEN" != "$DESTINO" && "$ORIGEN_PATH" != "$DESTINO_PATH" && "$DESTINO" != "." ]] || [[ "$DESTINO" == "." && "$ORIGEN" != "$ORIGEN_PATH" ]]; then
	if [ -e "$ORIGEN" ]; then
		if [ -d "$DESTINO" ]; then
			if [ ! -e "$DESTINO$ORIGEN" ]; then
				RETVAL=0
				mv "$ORIGEN" "$DESTINO"
				logMessage "$COMANDO" "El archivo \"$ORIGEN\" se movió exitosamente al destino \"$DESTINO\"." "0"
			else
				RETVAL=1
				logMessage "$COMANDO" "El archivo a mover \"$ORIGEN\" ya existe en el directorio destino \"$DESTINO\". Los archivos duplicados se guardan en la carpeta \"$DPLDIR\" dentro del directorio destino." "1"
				if [ -d "$DESTINO$DPLDIR" ]; then
					getProxNroSecuencia
					NRO_COPIA="$?"
					mv "$ORIGEN" "$DESTINO$DPLDIR$ORIGEN.$NRO_COPIA"
					logMessage "$COMANDO" "El archivo ya estaba duplicado, se creo otra copia numerada $NRO_COPIA." "0"
				else 
					mkdir "$DESTINO$DPLDIR"
					mv "$ORIGEN" "$DESTINO$DPLDIR"
					logMessage "$COMANDO" "Se creo el directorio \"$DPLDIR\" y se movió adentro el archivo." "0"
				fi
			fi
		else
			RETVAL=4
			logMessage "$COMANDO" "El destino especificado \"$DESTINO\" no existe o no es un directorio valido. No se puede mover el archivo." "2"
		fi
	else
		RETVAL=3
		logMessage "$COMANDO" "El origen especificado \"$ORIGEN\" no existe. No se puede mover el archivo." "2"
	fi
else
	RETVAL=2
	logMessage "$COMANDO" "El origen y destino especificados son el mismo. No se hace ningun movimiento." "2"
fi

exit "$RETVAL"


