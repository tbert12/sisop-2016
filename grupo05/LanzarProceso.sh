#!/bin/bash

TRUE=1
FALSE=0

logMessage () {
	CALLED_FROM_COMMANDLINE=$1
	COMANDO=$2
	MSG=$3
	MSG_TYPE=$4

	if [ -n "$COMANDO" ]; then
		bash GrabarBitacora.sh "$COMANDO" "$MSG" "$MSG_TYPE"
	fi

	if [ $CALLED_FROM_COMMANDLINE -eq $TRUE ]; then
		echo "$MSG"
	fi
}

if [ "$0" == "LanzarProceso.sh" -o "$0" == "./LanzarProceso.sh" ]; then
	CALLED_FROM_COMMANDLINE=$TRUE
else
	CALLED_FROM_COMMANDLINE=$FALSE
fi

if [ $# -eq 0 ]; then
	echo "No se especificaron argumentos para la función. No se pasó como parámetro el proceso a lanzar."
	if [ $CALLED_FROM_COMMANDLINE -eq $TRUE ]; then
		exit 4
	else
		return 4
	fi
fi

if [[ $* == *--foreground* ]] || [[ $* == *-f* ]]; then
	PROCESS=$2
	COMANDO=$3
else
	PROCESS=$1
	COMANDO=$2
fi

source funcionesDeChequeo.sh
chequearAmbienteInicializado
AMBIENTE_ESTA_INICIALIZADO=$?
if [ $AMBIENTE_ESTA_INICIALIZADO -eq 0 ]; then	# Variable de entorno booleana.
	PROCESS_NAME=`echo "${PROCESS##*/}" | awk '{print $1;}'`
	PROCESS_NAME="${PROCESS_NAME:0:15}"
	PID=$(pgrep "$PROCESS_NAME" | tail -n 1)
	if [ -z "$PID" ]; then
		if [[ $* == *--foreground* ]] || [[ $* == *-f* ]]; then
			$PROCESS
			START_RESULT=$?
		else
			$PROCESS &
			START_RESULT=$?
		fi

		if [ "$START_RESULT" -eq 0 ]; then
			RETVAL=0
			logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "El proceso \"$PROCESS\" ha sido lanzado exitosamente." "0"
		else
			RETVAL=2
			logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "No se pudo lanzar el proceso \"$PROCESS\"" "2"
		fi
	else
		RETVAL=1
		logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "El proceso $PROCESS ya está en ejecución. Su PID es $PID" "1"
	fi
else
	RETVAL=3
	logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "El ambiente no fue inicializado. El proceso \"$PROCESS\" no puede ser lanzado." "2"
fi

if [ $CALLED_FROM_COMMANDLINE -eq $TRUE ]; then
	exit "$RETVAL"
else
	return "$RETVAL"
fi
