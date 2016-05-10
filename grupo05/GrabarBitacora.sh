COMANDO=$1	# Comando, nombre del archivo de log

MSG=$2	# Mensaje a loggear

if [ -z ${3+x} ]; then		# El tercer argumento es el tipo de mensaje
	MSG_TYPE="INFO";	# INFO es tipo por default
else
	if [ $(($3)) -eq 2 ]; then		# Tipo 2 es ERROR
		MSG_TYPE="ERR"
	elif [ $(($3)) -eq 1 ]; then		# Tipo 1 es WARNING
		MSG_TYPE="WAR"
	else				# Tipo 0 es INFORMATIVO
		MSG_TYPE="INFO"
	fi
fi

if [ -z $LOGSIZE ]		# Si no está definida o es nulo, usa LOGSIZE=0
  then
	LOGSIZE=0
fi

DATE=`date +%d/%m/%Y" "%H:%M:%S`	# Fecha actual

# Escribo registro de log al final del archivo
# Si el archivo de bitacora no existe, creo uno nuevo
BITACORA="$LOGDIR$COMANDO.log"
if [ -n "$MSG" ]; then		# Solo loggeo mensajes no vacios.
	echo "$USER $DATE $COMANDO [$MSG_TYPE]: $MSG" >> $BITACORA

	# Si el tamanio del archivo supera LOGSIZE se trunca a ultimas 50 lineas
	CURRENT_LOGSIZE="$(wc -c < $BITACORA)"
	if [ -z ${LOGSIZE+x} -a ${LOGSIZE:-0} -gt 0 -a $((CURRENT_LOGSIZE)) -gt $((${LOGSIZE:-0} * 1024)) ]; then
        	LAST_REGS=`tail -n 50 "$BITACORA"`
        	rm "$BITACORA"
        	echo "$LAST_REGS" > $BITACORA
        	echo "$USER $DATE $COMANDO [INFO]: LOG EXCEDIDO" >> $BITACORA
	fi
fi

exit 0
