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
	if [ "$aux" -eq "$1" ]
	  then
		echo 0
	else
		echo 1
	fi
}

# Obtener la fecha de la ultima adjudicacion
obtenerFechaUltAdjudicacion() {
	if [ -s "$ARCH_FECHAS_ADJ" ]
	  then
		# Agarro la ultima linea del archivo FechasAdj.csv
		ult_adj=$(tail -n 1 "$ARCH_FECHAS_ADJ")
		if [ -n "$ult_adj" ]
		  then
			# Extraigo la fecha y reformateo a YYYYMMDD
			fecha_ult_adj=${ult_adj:6:4}${ult_adj:3:2}${ult_adj:0:2}
			return 0
		fi
	fi
	#####cdp
	sh GrabarBitacora.sh "$0" "COME FIND ME, I NEED YOU OBI WAN KENOBI" '1'
	#####
	fecha_ult_adj=0
	return 1
}

# Rechazo de archivo moviendolo a $NOKDIR y loggeo de explicacion
rechazarArchivo() {
	nom_arch_rechazado="$1"
	razon_rechazo="$2"

	sh MoverArchivo.sh "$ARRIDIR$nom_arch_rechazado" "$NOKDIR$nom_arch_rechazado"
	RES_MOV=$?
	### Verificar "$?" igual 0?, hablar con buby
	sh GrabarBitacora.sh "RecibirOfertas.sh" "Archivo $ARRIDIR$nom_arch_rechazado rechazado y movido a $NOKDIR$nom_arch_rechazado, por $razon_rechazo"
}


nro_ciclo=0
ARCH_CONCESIONARIOS="$MAEDIR""concesionarios.csv"
ARCH_FECHAS_ADJ="$MAEDIR""FechasAdj.csv"
# Archivos de novedades llegan en la forma $ARRIDIR<cod_concesionario>_<aniomesdia>.csv


# daemon
while :
do
	# Incremento e imprimo el número de ciclo
	((nro_ciclo+=1))
	sh GrabarBitacora.sh "$0" "ciclo nro. $nro_ciclo"

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
		if [ -n "$text" -a validarFormatoNombreArchivo "$nom_arch" ]
		  then
			fecha_arch=${nom_arch:5:8}	# Formato YYYYMMDD
			fecha_valida=$(date -d "$fecha_arch")

			# Obtengo fecha de ultima adjudicacion y fecha de hoy para comparaciones
			fecha_ult_adj=0
			obtenerFechaUltAdjudicacion # modifica $fecha_ult_adj
			fecha_hoy=$(date +%Y%m%d)

			# Hago los chequeos de fecha valida, menor o igual a hoy, y mayor a la de adj. obtenida
			if [ -n "$fecha_valida" -a $fecha_arch -gt $fecha_ult_adj -a $fecha_hoy -ge $fecha_arch ]
			  then
				# Chequeo existencia del concesionario
				linea_concesionario=$(cat "$ARCH_CONCESIONARIOS" | grep ";${nom_arch:0:4}$")
				if [ -n "$linea_concesionario" ]
				  then
					### Verificar funcionamiento de esto
					# Chequeo tamanio del archivo mayor a 0
					if [ $(wc -c < "$linea_arch") -gt 1 ] # semialt.: [ -s "$linea_arch" ]
					  then
						sh MoverArchivo.sh "$linea_arch" "$OKDIR$nom_arch"
						RES_MOV=$?
						### Verificar "$?" igual a 0?, hablar con buby
						sh GrabarBitacora.sh "$0" "Archivo $linea_arch aceptado y movido a $OKDIR$nom_arch"
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

		#####cdp
	if [ false ] #### "$(ls -A "$OKDIR")" ]	### DOBLES QUOTES: puede fallar, en cuyo caso buscar otra forma de hacer este chequeo
	  then # hay archivos aceptados en $OKDIR para procesar
		## Lanza ProcesarOfertas sin ningun parametro
		sh LanzarProceso.sh "sh ProcesarOfertas.sh" "$0"
		if [ $? -eq 0 ] ### Chequear con buby
		  then
			sh GrabarBitacora.sh "$0" "ProcesarOfertas corriendo bajo el no.: " ###NECESITO EL PID DE P.O.
		elif [ $? -eq 1 ]
			sh GrabarBitacora.sh "$0" "B" ####
		else
			sh GrabarBitacora.sh "$0" "C" ####
	fi

	sleep $SLEEPTIME
done
