#!/bin/bash

logMessage () {
	COMANDO=$1
	MSG=$2
	MSG_TYPE=$3

	echo "$MSG"
	if [ -n "$COMANDO" ]; then
		bash GrabarBitacora.sh "$COMANDO" "$MSG" "$MSG_TYPE"
	fi
}

# Elimina los archivos auxiliares del proceso,
# que deben terminar con las iniciales del mismo y extensión .aux
borrarArchAuxiliares () {
	INICIALES=$(tr -dc '[:upper:]' <<< "$1")
	find "$GRUPO" -name "*_$INICIALES.aux" -delete
}


if [ $# -eq 0 ]; then
	echo "No se especificaron argumentos para la función. No se pasó como parámetro el proceso a detener."
	exit 2
fi

PROCESS_NAME=$1		# Nombre del proceso a matar.
COMANDO=$2	# Comando desde donde se invoca este script.

if [ -z ${3+x} ]; then	# PID optativo, para detener un unico proceso cuando hay varios con el mismo nombre.
	PROCESS_NAME_FIRSTWORD=`echo "${PROCESS_NAME##*/}" | awk '{print $1;}'`
	PROCESS_NAME_FIRSTWORD="${PROCESS_NAME_FIRSTWORD:0:15}"
	PID=$(pgrep "$PROCESS_NAME_FIRSTWORD" | tail -n 1)
else
	PID=$3
fi

if [ -z "$PID" ]; then
	STOP_RESULT=1
else
	kill "$PID"
	STOP_RESULT=$?
fi

if [ "$STOP_RESULT" -eq 0 ]; then
	source funcionesDeChequeo.sh
	chequearAmbienteInicializado
	AMBIENTE_ESTA_INICIALIZADO=$?
	if [ $AMBIENTE_ESTA_INICIALIZADO -eq 0 ]; then
		borrarArchAuxiliares "$PROCESS_NAME"
	fi

	if [ -z "$PID" ]; then
		logMessage "$COMANDO" "El proceso $PROCESS_NAME ha sido detenido exitosamente." "0"
	else
		logMessage "$COMANDO" "El proceso $PROCESS_NAME con $PID ha sido detenido exitosamente." "0"
	fi
else
	if [ -z "$PID" ]; then
		logMessage "$COMANDO" "El proceso $PROCESS_NAME no pudo ser detenido. Verifique el nombre ingresado." "2"
	else
		logMessage "$COMANDO" "El proceso $PROCESS_NAME con $PID no pudo ser detenido." "2"
	fi
fi

exit "$STOP_RESULT";

