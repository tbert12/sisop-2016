PROCESS_NAME=$1		# Nombre del proceso a matar.
COMANDO=$2	# Comando desde donde se invoca este script.

if [ -z ${3+x} ]; then	# PID optativo, para detener un unico proceso cuando hay varios con el mismo nombre.
	OUTPUT=`start-stop-daemon --stop --name "$PROCESS_NAME"`
	STOP_RESULT=$?
else
	PID=$3
	OUTPUT=`start-stop-daemon --stop --name "$PROCESS_NAME" --pid "$PID"`
	STOP_RESULT=$?
fi

if [ "$STOP_RESULT" -eq 0 ]; then
	if [ -z ${PID+x} ]; then
		bash GrabarBitacora.sh "$COMANDO" "El proceso $PROCESS_NAME ha sido detenido exitosamente."
		echo "El proceso $PROCESS_NAME ha sido detenido exitosamente."
	else
		bash GrabarBitacora.sh "$COMANDO" "El proceso $PROCESS_NAME con PID $PID ha sido detenido exitosamente."
		echo "El proceso $PROCESS_NAME con PID $PID ha sido detenido exitosamente."
	fi
elif [ "$STOP_RESULT" -eq 1 ]; then
	echo "$OUTPUT"
	bash GrabarBitacora.sh "$COMANDO" "$OUTPUT" 1
else
	echo "Ocurrio un error al invocar al comando start-stop-daemon. No se pudo detener el proceso $PROCESS_NAME."
	bash GrabarBitacora.sh "$COMANDO" "Ocurrio un error al invocar al comando start-stop-daemon. No se pudo detener el proceso $PROCESS_NAME." 2
fi

exit "$STOP_RESULT";

