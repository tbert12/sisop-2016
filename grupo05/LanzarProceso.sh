logMessage () {
	CALLED_FROM_COMMANDLINE=$1
	COMANDO=$2
	MSG=$3
	MSG_TYPE=$4

	if [ "$CALLED_FROM_COMMANDLINE" = true ]; then
		echo "$MSG"
	else
		sh GrabarBitacora.sh "$COMANDO" "$MSG" "$MSG_TYPE"
	fi
}

PROCESS=$1
COMANDO=$2

if [ $(readlink -f /proc/$(ps -o ppid:1= -p $$)/exe) != $(readlink -f "$SHELL") ]; then
	CALLED_FROM_COMMANDLINE=false
else
	CALLED_FROM_COMMANDLINE=true
fi

PID=`pgrep "$PROCESS"`
if [ -z "$PID" ]; then
	$PROCESS &
	START_RESULT=$?

	if [ "$START_RESULT" -eq 0 ]; then
		RETVAL=0
		logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "El proceso $PROCESS ha sido lanzado exitosamente." "0"
	else
		RETVAL=2
		logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "No se pudo lanzar el proceso $PROCESS" "2"
	fi
else
	RETVAL=1
	logMessage "$CALLED_FROM_COMMANDLINE" "$COMANDO" "El proceso $PROCESS ya esta en ejecucion. El PID es $PID" "1"
fi

return "$RETVAL"
