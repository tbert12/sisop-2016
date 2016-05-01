#! /bin/bash
# 
# Universidad de Buenos Aires
# Facultad de Ingenieria
#
# 75.08 Sistemas Operativos
# Trabajo Practico
# Autor: Grupo 5
#
# No recibe parametros
#
# Input:
#		Tabla de Fechas de adj. MAEDIR/FechasAdj.csv
# Ouput:
#		Archivos de sorteos PROCDIR/sorteos/<sorteoId>_<fecha de adjudicación>
# 		Log del Comando LOGDIR/GenerarSorteo.log
#

#funcion que genera un sorteo para una fecha y un ID
generarSorteo() {
	
	#Fecha de adjudicacion
	FECHAADJ=$1
	#SorteoID
	SORTEOID=$2

	#Inicio el log grabando "Inicio de Sorteo"
	bash GrabarBitacora.sh GenerarSorteo "Inicio de Sorteo Numero: $SORTEOID de la fecha: $(echo $FECHAADJ | cut -c7-8)/$(echo $FECHAADJ | cut -c5-6)/$(echo $FECHAADJ | cut -c1-4)"

	#genera en NUMEROS_SORTEO un array con la secuencia de 1 a 168 random
	NUMEROS_SORTEO=($(seq 168 | shuf))

	#Archivo a guardar
	FILE="$PROCDIR""sorteos/$SORTEOID""_""$FECHAADJ.srt"

	#si el directorio PROCDIR/sorteos no existe lo creo
	if [ ! -d $PROCDIR"sorteos" ]
		then
			mkdir -p $PROCDIR"sorteos"
	fi

	#Verifico si el archivo ya esta creado
	if [ -w $FILE ]
		then
		#Si ya esta creado lo renombra con .backup
		mv $FILE $FILE".backup"

		#Avisa en el log
		bash GrabarBitacora.sh GenerarSorteo "El archivo: $FILE ya existia, se renombro por: $FILE.backup para no sobreescribirlo" 2
	fi

	#for guardando en sorteo y logueando.
	for i in $(seq 1 168)
	do
	    #Log con numero de sorteo y numero de orden
		bash GrabarBitacora.sh GenerarSorteo "Numero de orden: $i le corresponde el numero de sorteo: ${NUMEROS_SORTEO[$i]}"

		#Guardo en archivo
		echo $i";"${NUMEROS_SORTEO[$((i-1))]} >> $FILE
	done

	#Finalizo el log grabando "Fin de Sorteo"
	bash GrabarBitacora.sh GenerarSorteo "Fin de Sorteo Numero: $SORTEOID de la fecha: $(echo $FECHAADJ | cut -c7-8)/$(echo $FECHAADJ | cut -c5-6)/$(echo $FECHAADJ | cut -c1-4)"
}

#genera el id correspondiente para la fecha
generarId() {
	local FECHA=$1
	#echo "$PROCDIR"sorteos/*_$FECHA.srt
	
	#CUANDO HAY MAS DE UN ARCHIVO FALLA COMO ESCOPETA VIEJA
	if [ -f "$PROCDIR"sorteos/1_$FECHA.srt ] #hay un archivo 1_FECHA -> hay una secuecia de ID = nn + 1
		then
			ARCHIVOS=(`ls "$PROCDIR"sorteos/*_$FECHA.srt | sort -r`)
			ULT="${ARCHIVOS##*/}"
			ULT=${ULT:0:1}
			ID=$(expr $ULT + 1)
			echo $ID
	else
		#no hay ningun archivo -> ID = 1
		echo 1
	fi
}

#detecta la fecha de adjudicacion proxima y la aloja en FECHA_PROX_ADJ
fechaProximaAdjudicacion() {
	
	hoy=$(date +'%Y%m%d')
	local diferenciaMin=0
	local diferenciaActual=0
	local PROX=""

	while read -r linea 
	do
		if [ -n "$linea" ]
			then
			# Extraigo la fecha y reformateo a YYYYMMDD
			fecha_actual=$(echo "$linea" | cut -c7-10)$(echo "$linea" | cut -c4-5)$(echo "$linea" | cut -c1-2)
			
			#fecha de la linea del archivo es mayor que la de hoy
			if [ $fecha_actual -gt $hoy ] 
				then
					diferenciaActual=$(( $fecha_actual-$hoy ))
					if [  "$diferenciaActual" -lt "$diferenciaMin" ] || [ $diferenciaMin -eq 0 ]
						then
							#Esta mas cerca que una fecha comparada anteriormente || Todavia no se comparo ninguna
							diferenciaMin=$diferenciaActual
							PROX=$fecha_actual
					fi
			fi
		fi
	done < $ARCH_FECHAS_ADJ
	echo $PROX
}


# Inicializacion de Variables
#Tabla de fechas de adj
ARCH_FECHAS_ADJ="$MAEDIR""FechasAdj.csv"


#For de las fechas de adjudicacion
if [ -r "$ARCH_FECHAS_ADJ" ]
	then
		# Extraigo la fecha de la proxima adjudicacion y reformateo a YYYYMMDD
		fecha_adj=$(fechaProximaAdjudicacion)
		
		#genero el sorteo
		generarSorteo $fecha_adj $(generarId "$fecha_adj")
	#exit 0
else
	bash GrabarBitacora.sh GenerarSorteo "No hay archivo de adjudicacion, el proceso no se realizo" 3
	#exit 1
fi