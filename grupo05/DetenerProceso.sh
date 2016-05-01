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

return "$STOP_RESULT";

