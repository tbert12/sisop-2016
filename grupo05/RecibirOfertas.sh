#!/bin/bash

#####De prueba
ARRIDIR="ARRIDIR/"
MAEDIR="MAEDIR/"
NOKDIR="NOKDIR/"
OKDIR="OKDIR/"
SLEEPTIME=10 #segundos
#####


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


# Obtener la fecha de la ultima adjudicacion
obtenerFechaUltAdjudicacion() {
	fecha_ult_adj=0

	if [ -s "$ARCH_FECHAS_ADJ" ]
	  then
		ret_val=1  # Si no es corregido, no hay fecha de adj. pasada

		fecha_hoy=$(date +%Y%m%d)
		tac "$ARCH_FECHAS_ADJ" > fechas_adj_inversoAUX.aux

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
		done < fechas_adj_inversoAUX.aux  # Leo el archivo de abajo para arriba hasta encontrar la primera adjudicacion anterior o igual a hoy
	else
		#####cdp
		bash GrabarBitacora.sh "$0" "COME FIND ME, I NEED YOU OBI WAN KENOBI" '1'  # No hay archivo de adjudicacion no vacio
		###echo "YOURE MY ONLY HOPE"
		ret_val=2
	fi

	if [ -e fechas_adj_inversoAUX.aux ]
	  then
		rm fechas_adj_inversoAUX.aux
	fi

	if [ $ret_val -gt 0 ]
	  then
		bash GrabarBitacora.sh "$0" "No se encontro fecha de adjudicacion pasada"
	fi
	return $ret_val
}


# Rechazo de archivo moviendolo a $NOKDIR y loggeo de explicacion
rechazarArchivo() {
	nom_arch_rechazado="$1"
	razon_rechazo="$2"

	# mv
	bash MoverArchivo.sh "$ARRIDIR$nom_arch_rechazado" "$NOKDIR$nom_arch_rechazado"
	RES_MOV=$?
	### Verificar "$?" igual 0?, hablar con buby
	bash GrabarBitacora.sh "RecibirOfertas.sh" "Archivo $ARRIDIR$nom_arch_rechazado rechazado y movido a $NOKDIR$nom_arch_rechazado, por $razon_rechazo"
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
	bash GrabarBitacora.sh "$0" "ciclo nro. $nro_ciclo"
	##echo "ciclo nro. $nro_ciclo"

	# Obtengo fecha de ultima adjudicacion y fecha de hoy para comparaciones
	fecha_hoy=$(date +%Y%m%d)
	fecha_ult_adj=0
	obtenerFechaUltAdjudicacion  # modifica $fecha_ult_adj

	# Obtengo una lista de todos los archivos en la carpeta $ARRIDIR
	find "$ARRIDIR" -maxdepth 1 -type f > RecibirOfertasAUX.aux

	# Por cada archivo encontrado...
	while read -r linea_arch
	do
		# Chequeo que el tipo archivo sea del archivo mencione ´text´
		text=$(file "$linea_arch" | grep "text")
		# Extraigo nombre de archivo sin directorios
		nom_arch=$(echo "$linea_arch" | sed 's-.*/\([^/]*\)$-\1-g')

		# Verifico que el archivo sea de texto y el formato del nombre correcto
		if [ -n "$text" -a $(validarFormatoNombreArchivo "$nom_arch") -eq 0 ]
		  then
			fecha_arch=$(echo $nom_arch | cut -c6-13)  # Formato YYYYMMDD
			fecha_valida=$(date -d "$fecha_arch")

			# Hago los chequeos de fecha valida, menor o igual a hoy, y mayor a la de adj. obtenida
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
						bash MoverArchivo.sh "$linea_arch" "$OKDIR$nom_arch"
						RES_MOV=$?
						### Verificar "$?" igual a 0?, hablar con buby
						bash GrabarBitacora.sh "$0" "Archivo $linea_arch aceptado y movido a $OKDIR$nom_arch"
					else
						rechazarArchivo "$nom_arch" "encontrarse vacio"
					fi
				else
					rechazarArchivo "$nom_arch" "codigo de concesionario desconocido"
				fi
			else
				rechazarArchivo "$nom_arch" "fecha invalida o anterior a la ultima adjudicacion"
			fi
		else
			rechazarArchivo "$nom_arch" "invalido tipo o nombre del archivo"
		fi
	done < RecibirOfertasAUX.aux
	rm RecibirOfertasAUX.aux

	if [ "$(ls -A "$OKDIR")" ]	### DOBLES QUOTES: pueden fallar, en cuyo caso buscar otra forma de hacer este chequeo
	  then # hay archivos aceptados en $OKDIR para procesar
		##echo "Llamaria PO.sh"
		# Lanza ProcesarOfertas sin ningun parametro
		bash LanzarProceso.sh "bash ProcesarOfertas.sh" "$0"
		if [ $? -eq 0 ] ### Chequear con buby
		  then
			bash GrabarBitacora.sh "$0" "ProcesarOfertas corriendo bajo el no.: " ###NECESITO EL PID DE P.O.
		elif [ $? -eq 1 ]
			bash GrabarBitacora.sh "$0" "B" #'X' ####
		else
			bash GrabarBitacora.sh "$0" "C" #'X' ####
	fi

	sleep $SLEEPTIME
done
