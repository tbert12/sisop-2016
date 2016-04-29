logMessage () {
	CALLED_FROM_COMMANDLINE=$1
	COMANDO=$2
	MSG=$3
	MSG_TYPE=$4

	if [ "$CALLED_FROM_COMMANDLINE" -ne 0 ]; then
		echo "$MSG"
	else
		if [ ! -z "$COMANDO" ]; then
			bash GrabarBitacora.sh "$COMANDO" "$MSG" "$MSG_TYPE"
		fi
	fi
}

PROCESS=$1
COMANDO=$2

if [ $(readlink -f /proc/$(ps -o ppid:1= -p $$)/exe) != $(readlink -f "$SHELL") ]; then
	CALLED_FROM_COMMANDLINE=0	# 0 = false
else
	CALLED_FROM_COMMANDLINE=1	# 1 = true
fi

if [ "$AMBIENTE_INICIALIZADO" -ne 0 ]; then	# Variable de entorno booleana.
	PROCESS_NAME=`echo "$PROCESS" | awk '{print $1;}'`
	PID=$(pgrep "$PROCESS_NAME" | tail -n 1)
	if [ -z "$PID" ]; then
		$PROCESS &
		START_RESULT=$?

		if [ "$START_RESULT" -eq 0 ]; then
			RETVAL=0
			logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "El proceso \"$PROCESS\" ha sido lanzado exitosamente." "0"
		else
			RETVAL=2
			logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "No se pudo lanzar el proceso \"$PROCESS\"" "2"
		fi
	else
		RETVAL=1
		logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "El proceso $PROCESS ya esta en ejecucion. El PID es $PID" "1"
	fi
else
	RETVAL=2
	logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "El ambiente no fue inicializado. El proceso \"$PROCESS\" no puede ser lanzado." "2"
fi

exit "$RETVAL"
