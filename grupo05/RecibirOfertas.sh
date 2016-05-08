#!/bin/bash


validarFormatoNombreArchivo() {
	# Formato buscado: <cod_concesionaria_de_4_digitos>_<aniomesdia>.csv
	aux=$(echo $1 | grep '^\([0-9]\{4,4\}_[12][0-9]\{3,3\}[0-1][0-9][0-3][0-9]\.[cC][sS][vV]\)$')
	if [ "$aux" = "$1" ]
	  then
		echo 0
	else
		echo 1
	fi
}


# Obtener la fecha de la última adjudicación
obtenerFechaUltAdjudicacion() {
	fecha_ult_adj=0

	if [ -s "$ARCH_FECHAS_ADJ" ]
	  then
		ret_val=1  # Si no es corregido, no hay fecha de adj. pasada

		fecha_hoy=$(date +%Y%m%d)
		tac "$ARCH_FECHAS_ADJ" > "$DATDIR"fechas_adj_inverso_RO.aux

		while read -r linea_adj
		do
			if [ -n "$linea_adj" ]
			  then
				# Extraigo la fecha y reformateo a YYYYMMDD
				fecha_adj=$(echo "$linea_adj" | cut -c7-10)$(echo "$linea_adj" | cut -c4-5)$(echo "$linea_adj" | cut -c1-2)

				if [ $fecha_hoy -ge $fecha_adj ]
				  then
					fecha_ult_adj=$fecha_adj
					ret_val=0
					break
				fi
			fi
		done < "$DATDIR"fechas_adj_inverso_RO.aux  # Leo el archivo de abajo para arriba hasta encontrar la primera adjudicación anterior o igual a hoy
	else
		#### Solo salta si falta el archivo, lo cual no debería
		bash GrabarBitacora.sh "RecibirOfertas" "Falta archivo maestro ""$MAEDIR""FechasAdj.csv" '1'  # No hay archivo de adjudicación no vacío
		###echo "YOURE MY ONLY HOPE"
		ret_val=2
	fi

	if [ -e "$DATDIR"fechas_adj_inverso_RO.aux ]
	  then
		rm "$DATDIR"fechas_adj_inverso_RO.aux
	fi

	if [ $ret_val -gt 0 ]
	  then
		bash GrabarBitacora.sh "RecibirOfertas" "No se encontró fecha de adjudicación pasada"
	fi
	return $ret_val
}


# Rechazo de archivo moviendolo a $NOKDIR y loggeo de explicacion
rechazarArchivo() {
	nom_arch_rechazado="$1"
	razon_rechazo="$2"

	# mv
	bash MoverArchivos.sh "$ARRIDIR$nom_arch_rechazado" "$NOKDIR" "RecibirOfertas"
	RES_MOV=$?
	if [ $RES_MOV -eq 0 ]
	  then
		bash GrabarBitacora.sh "RecibirOfertas" "Archivo $ARRIDIR$nom_arch_rechazado rechazado y movido a $NOKDIR$nom_arch_rechazado, por $razon_rechazo"
	fi
}



# Los archivos de novedades llegan a $ARRIDIR en la forma <cod_concesionario>_<aniomesdia>.csv
ARCH_CONCESIONARIOS="$MAEDIR""concesionarios.csv"
ARCH_FECHAS_ADJ="$MAEDIR""FechasAdj.csv"

nro_ciclo=0

# daemon
while :
do
	# Incremento e imprimo el número de ciclo
	nro_ciclo=$((nro_ciclo+1))
	bash GrabarBitacora.sh "RecibirOfertas" "ciclo nro. $nro_ciclo"
	#echo "ciclo nro. $nro_ciclo"

	# Obtengo fecha de última adjudicación y fecha de hoy para comparaciones
	fecha_hoy=$(date +%Y%m%d)
	fecha_ult_adj=0
	obtenerFechaUltAdjudicacion  # modifica $fecha_ult_adj

	# Obtengo una lista de todos los archivos en la carpeta $ARRIDIR
	find "$ARRIDIR" -maxdepth 1 -type f > "$DATDIR"arch_arr_RO.aux

	# Por cada archivo encontrado...
	while read -r linea_arch
	do
		# Chequeo que el tipo del archivo mencione ´text´
		text=$(file "$linea_arch" | grep "text")
		# Extraigo nombre de archivo sin directorios
		nom_arch=$(echo "$linea_arch" | sed 's-.*/\([^/]*\)$-\1-g')

		# Verifico que el archivo sea de texto y el formato del nombre correcto
		if [ -n "$text" -a $(validarFormatoNombreArchivo "$nom_arch") -eq 0 ]
		  then
			fecha_arch=$(echo $nom_arch | cut -c6-13)  # Formato YYYYMMDD
			fecha_valida=$(date -d "$fecha_arch")

			# Hago los chequeos de fecha válida, menor o igual a hoy, y mayor a la de adj. obtenida
			if [ -n "$fecha_valida" -a $fecha_arch -gt $fecha_ult_adj -a $fecha_hoy -ge $fecha_arch ]
			  then
				# Chequeo existencia del concesionario
				linea_concesionario=$(cat "$ARCH_CONCESIONARIOS" | grep ";$(echo $nom_arch | cut -c1-4)")
				if [ -n "$linea_concesionario" ]
				  then
					# Chequeo tamanio del archivo mayor a 0
					if [ $(wc -c < "$linea_arch") -gt 1 ]   # semialternativa: [ -s "$linea_arch" ]
					  then
						# mv
						bash MoverArchivos.sh "$linea_arch" "$OKDIR" "RecibirOfertas"
						RES_MOV=$?
						if [ $RES_MOV -eq 0 ]
						  then
							bash GrabarBitacora.sh "RecibirOfertas" "Archivo $linea_arch aceptado y movido a $OKDIR$nom_arch"
						fi
					else
						rechazarArchivo "$nom_arch" "encontrarse vacío"
					fi
				else
					rechazarArchivo "$nom_arch" "código de concesionario desconocido"
				fi
			else
				rechazarArchivo "$nom_arch" "fecha inválida o anterior a la última adjudicación"
			fi
		else
			rechazarArchivo "$nom_arch" "inválido tipo o nombre del archivo"
		fi
	done < "$DATDIR"arch_arr_RO.aux
	rm "$DATDIR"arch_arr_RO.aux 2> /dev/null

	if [ "$(ls -A "$OKDIR")" ]
	  then  # hay archivos aceptados en $OKDIR para procesar
		. "$BINDIR"LanzarProceso.sh "$BINDIR""ProcesarOfertas.sh" "RecibirOfertas"
		RES_LNZ=$?
		if [ $RES_LNZ -eq 0 ]
		  then
			PID=$(pgrep "ProcesarOfertas" | tail -n 1)
			bash GrabarBitacora.sh "RecibirOfertas" "ProcesarOfertas corriendo bajo el no.: $PID"
		elif [ $RES_LNZ -eq 1 ]
		  then
			bash GrabarBitacora.sh "RecibirOfertas" "Invocación de ProcesarOfertas pospuesta para el siguiente ciclo" '1'
		#else
			# No se pudo ejecutar ProcesarOfertas
		fi
	fi

	sleep $SLEEPTIME
done
